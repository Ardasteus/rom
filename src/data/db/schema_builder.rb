# Created by Matyáš Pokorný on 2019-05-13.

module ROM
	class SchemaBuilder
		TYPES = {
			String => :string,
			Integer => :int,
			Types::Boolean => :bool
		}
		
		def initialize(dvr)
			@dvr = dvr
		end
		
		def build(ctx)
			sch = DbSchema.new
			tabs = []
			trans = {}
			
			conv = ->(nm, *args) { ctx.convention(nm, *args) or @dvr.convention(nm, *args) }
			
			ctx.tables.each do |table|
				tab = sch.table(conv.call(:table, table.name.to_s))
				keys = []
				table.model.properties.each do |prop|
					name = if Types::Just[Model].accepts(prop.type) or prop.attribute?(ReferenceAttribute)
						tb, col = resolve_ref(ctx, prop)
						sfx = prop.attribute(SuffixAttribute)
						
						from_n = conv.call(:table, table.name.to_s)
						to_n = conv.call(:table, tb.name.to_s)
						
						[:fk_column, from_n, to_n, col.name, (sfx == nil ? '' : sfx.suffix)]
					elsif table.keys.include?(prop)
						[:pk_column, table.name, prop.name]
					else
						[:column, table.name, prop.name]
					end
					
					col = tab.column(conv.call(*name), get_type(ctx, prop))
					trans[prop] = col
					keys << col if table.keys.include?(prop)
					idx = prop.attribute(IndexAttribute)
					tab.index(conv.call(:index, tab.name, idx.unique?, [col.name]), idx.unique?, col) unless idx == nil
				end
				tab.primary(conv.call(:pk_key, tab.name, keys.collect(&:name)), *keys)
				
				tabs << tab
			end
			
			ctx.tables.each do |table|
				table.model.properties.select { |i| Types::Just[Model].accepts(i.type) or i.attribute?(ReferenceAttribute) }.each do |prop|
					tb, col = resolve_ref(ctx, prop)
					from = trans[prop]
					to = trans[col]
					sch.reference(conv.call(:fk_key, from.table.name, to.table.name, from.name, to.name), from, to)
				end
			end
			
			sch
		end
		
		def get_type(ctx, prop)
			bt, null = base_type(prop.type)
			if bt < Model
				_, other = resolve_ref(ctx, prop)
				bt, _ = base_type(other.type)
				return get_type(ctx, prop) if bt < Model
				raise("Type '#{bt.name}' may not be resolved as a database type!") unless TYPES.has_key?(bt)
			end
			raise('Nullable types are currently not supported!') if null
			
			@dvr.type(TYPES[bt])
		end
		
		def resolve_ref(ctx, prop)
			bt, _ = base_type(prop.type)
			ref = prop.attribute(ReferenceAttribute)
			table = nil
			other = nil
			if ref == nil
				table = ctx.tables.select { |i| i.model <= bt }
				if table.size == 0
					raise('Referred model is not part of given context!')
				elsif table.size == 1
					cols = table.first.keys
					raise('There are no candidate key columns in target table!') if cols.size == 0
					raise('There are multiple candidate key columns in target table!') if cols.size > 1
					other = cols.first
					table = table.first
				else
					raise('There are multiple candidate models for given reference!')
				end
			else
				table = ctx.tables.find { |i| i.name == ref.table }
				raise("Target table '#{ref.table}' not found!") if table == nil
				other = table.model.class.properties.find { |i| i.name == ref.column }
				raise("Target column '#{ref.column}' not found!") if other == nil
			end
			
			[table, other]
		end
		
		def base_type(type)
			null = false
			base = nil
			if type.is_a?(Types::Type)
				case type
					when Types::Just
						base = type.type
					when Types::Union
						if type.types.size == 2 and type.types.any? { |i| i == NilClass }
							base = type.types.find { |i| i != NilClass }
							null = true
						else
							raise("Union is only supported with NilClass as a database type!")
						end
					when Types::Boolean
						base = type
					else
						raise("Type '#{type.name}' may not be resolved as a database type!")
				end
			elsif type.is_a?(Class)
				base = type
			end
			
			raise("Type '#{type.name}' may not be resolved as a database type!") unless (base < Model or TYPES.has_key?(base))
			
			[base, null]
		end
		
		private :base_type
	end
end