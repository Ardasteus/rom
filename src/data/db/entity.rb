# Created by Matyáš Pokorný on 2019-05-18.

module ROM
	class Entity
		def entity_changed?
			@changes.size > 0
		end
		
		def entity_changes
			@changes
		end
		
		def entity_table
			@tab
		end
		
		def entity_model
			@mod
		end
		
		def flush_changes
			ret = @changes
			@changes = {}
			
			ret
		end
		
		def initialize(tab, vals = {})
			@mod = tab.table.model.new(vals)
			@tab = tab
			@changes = {}
			@promises = {}

			tab.table.model.properties.each do |prop|
				sym = prop.name.to_sym
				
				if prop.type <= Model
					self.class.send(:define_method, sym) do
						
					end
				else	
					self.class.send(:define_method, sym) { @mod[sym] }
				end

				self.class.send(:define_method, "#{sym.to_s}=".to_sym) do |val|
					if @mod[sym] != val
						@changes[sym] = val
						@mod[sym] = val
					end
				end
			end

			vals.each_pair do |k, v|
				raise('References are not supported yet!') if tab.table.model[k].type <= Model
				@mod[k] = v
			end
		end
		
		def [](key)
			@mod[key]
		end
		
		def []=(key, value)
			@mod[key] = value
		end
		
		def is_a?(klass)
			self.class <= klass or @mod.class.is_a?(klass)
		end
	end
end