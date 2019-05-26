module ROM
	class DbContext
		include DbSeed
		
		def schema
			@sch
		end
		
		def tables
			@tabs.values
		end
		
		def initialize(db, sch)
			@db = db
			@sch = sch
			@tabs = {}
			
			maps = {}
			self.class.tables.each do |tab|
				t = sch.tables.find { |i| i.table == tab }
				lazy = {}
				map = { :map => EntityMapper.new(t, lazy), :lazy => lazy }
				col = TableCollection.new(@db, self, t, map[:map])
				self.class.send(:define_method, tab.name.to_sym) do
					col
				end
				@tabs[tab.name.to_sym] = col
				maps[tab] = map
			end
			
			@sch.references.each do |ref|
				maps[ref.from.table.table][:lazy][ref.from.name.to_sym] = LazyLoader.new(@db, ref.target.table, maps[ref.target.table.table][:map])
			end
		end
		
		def seed_context(stat)
			self.class.tables.select { |i| i.model <= DbSeed and stat.new?(i.name.to_sym) }.each do |tab|
				tab.model.seed(@tabs[tab.name.to_sym])
			end
			
			self.class.seed(self) if stat.regenerated?
		end
		
		def [](key)
			@tabs[key.to_sym]
		end
		
		def self.convention(nm, *args, &block)
			if block_given?
				@conv[nm] = block
			else
				@conv[nm]&.call(*args)
			end
		end
		
		def self.tables
			@tabs.values
		end
		
		# Prepares the DB context class
		# @return [void]
		def self.prepare_model
			@tabs = {}
			@conv = {}
		end
		
		# Prepares all subclasses
		# @param [Class] sub Type of subclass
		# @return [void]
		def self.inherited(sub)
			sub.prepare_model
		end
		
		def self.table(name, mod, *att)
			name = name.to_s
			raise("Table '#{name}' already defined!") if @tabs.has_key?(name)
			@tabs[name] = Table.new(name, mod, *att)
		end
		
		class Table
			def name
				@name
			end
			
			def model
				@model
			end
			
			def attributes
				@attributes
			end
			
			def keys
				@keys
			end
			
			def auto_properties
				@auto
			end
			
			def initialize(nm, mod, *att)
				@name = nm
				@model = mod
				@attributes = att
				@keys = mod.properties.select { |i| i.attribute?(KeyAttribute) }
				@auto = mod.properties.select { |i| i.attribute?(AutoAttribute) }
				if @keys.size == 0
					id = mod.properties.find { |i| i.name.downcase == 'id' }
					unless id == nil
						@keys << id
						@auto << id unless @auto.include?(id)
					end
				end
			end
		end
		
		class TableCollection < DbCollection
			def initialize(db, ctx, tab, map)
				@db = db
				@ctx = ctx
				@tab = tab
				@map = map
				@type = tab.table.model
			end
			
			def add(*entities, **opt)
				ret = []
				entities.each do |e|
					ret << add_recursive(e, (opt[:deep] or true))
				end
				
				(ret.size == 1 ? ret.first : ret)
			end
			
			def add_recursive(mod, deep, *history)
				raise('Invalid model type!') unless mod.is_a?(@type)
				mod = mod.entity_model if mod.is_a?(Entity)
				
				row = {}
				vals = {}
				mod.class.properties.each do |prop|
					sym = prop.name.to_sym
					v = mod[sym]
					vals[sym] = v
					
					next if @tab.table.auto_properties.include?(prop)
					col = @tab.columns.find { |i| i.mapping == prop }
					
					row[col.name] = Queries::ConstantValue.new(if col.reference != nil and v != nil
						tgt = col.reference.target
						unless v.is_a?(Entity)
							if deep
								raise('Recursive insert required!') if history.include?(v)
								v = @ctx[tgt.table.table.name].add_recursive(v, deep, mod, *history)
								vals[sym] = v
							else
								raise('Reference not satisfied for insert operation!')
							end
						end
						v[tgt.mapping.name.to_sym]
					else
						v
					end)
				end
				
				@db.execute(@db.driver.insert(@tab, row))
				
				if @tab.table.auto_properties.size == 1
					prop = @tab.table.auto_properties.first
					vals[prop.name.to_sym] = @db.last_id
				end
				
				Entity.new(@tab, vals)
			end
			
			def update(*entities, **opt)
				entities.each do |e|
					raise('Only entities may be updated!') unless e.is_a?(Entity)
					update_recursive(e, (opt[:deep] or true), (opt[:full] or false))
				end
			end
			
			def update_recursive(e, deep, full, *history)
				raise('Only entities may be updated!') unless e.is_a?(Entity)
				
				with = {}
				changes = e.flush_changes
				e.entity_model.class.properties.each do |prop|
					k = prop.name.to_sym
					changed = changes.has_key?(k)
					v = e[k]
					col = @tab.columns.find { |i| i.mapping.name.to_s == k.to_s }
					if v.is_a?(Entity)
						if full or (deep and (changed or v.entity_changed?))
							raise('Recursive update required!') if history.include?(v)
							tgt = col.reference.target
							sym = tgt.mapping.name.to_sym
							old = v[sym]
							@ctx[tgt.table.table.name].update_recursive(v, deep, e, *history) if v.entity_changed?
							new = v[sym]
							with[col.name] = Queries::ConstantValue.new(new) unless new == old
						end
					elsif v.is_a?(Model)
						if full or deep
							raise('Recursive insert required!') if history.include?(v)
							tgt = col.reference.target
							v = @ctx[tgt.table.table.name].add_recursive(v, deep, full, e, *history)
							with[col.name] = Queries::ConstantValue.new(v[tgt.mapping.name.to_sym])
						end
					elsif changed
						with[col.name] = Queries::ConstantValue.new(v)
					end
				end
				
				@db.execute(@db.driver.update(@tab, get_matcher(e), with)) if with.size > 0
			end
			
			def delete(e = nil)
				raise('Block cannot be used when entity was given!') if e != nil and block_given?
				if e == nil
					raise('Matching function expected!') unless block_given?
					raise('Only entities may be deleted!') unless e.is_a?(Entity)
					where = yield(@tab.double)
					raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
				else
					where = get_matcher(e)
				end
				
				@db.execute(@db.driver.delete(@tab, where))
			end
			
			def get_matcher(e)
				raise('Entity has no primary keys!') unless @tab.table.keys.size > 0
				
				@tab.table.keys.reduce(nil) do |n, key|
					col = e.entity_table.columns.find { |i| i.mapping == key }
					eq = Queries::ColumnValue.new(col) == e[key.name.to_sym]
					(n == nil ? eq : n.and(eq))
				end
			end
			
			def <<(e)
				add(e)
			end
			
			def select
				expr = yield(@tab.double)
				raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
				SelectQuery.new(@db, @tab, @map, expr)
			end
			
			def collect
				expr = yield(@tab.double)
				raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
				CollectQuery.new(@db, @tab, expr)
			end
			
			def find(*keys, **named_keys)
				raise('Keys by-position cannot be mixed with keys by-name!') if keys.size > 0 and named_keys.size > 0
				if keys.size > 0
					raise("Expected #{@tab.table.keys.size} keys, got #{keys.size}!") if @tab.table.keys.size != keys.size
					i = -1
					expr = @tab.table.keys.reduce(nil) do |n, prop|
						col = Queries::ColumnValue.new(@tab.columns.find { |col| col.mapping == prop })
						i += 1
						next (n == nil ? col == keys[i] : n.and(col == keys[i]))
					end
				elsif named_keys.size > 0
					raise("Expected #{@tab.table.keys.size} keys, got #{named_keys.size}!") if @tab.table.keys.size != named_keys.size
					i = -1
					expr = @tab.table.keys.reduce(nil) do |n, prop|
						col = Queries::ColumnValue.new(@tab.columns.find { |col| col.mapping == prop })
						raise("Key '#{prop.name}' not found!") unless named_keys.has_key?(prop.name.to_sym)
						val = named_keys[prop.name.to_sym]
						i += 1
						next (n == nil ? col == val : n.and(col == val))
					end
				else
					expr = yield(@tab.double)
					raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
				end
				qry = @db.driver.find(@tab, expr)
				@db.query(qry).each do |row|
					return(@map.map(row))
				end
				
				nil
			end
			
			def sort_by
				expr = yield(@tab.double)
				raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
				EntitySortQuery.new(@db, @tab, @map, [Queries::Order.new(expr, :asc)])
			end
			
			def sort_by_desc
				expr = yield(@tab.double)
				raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
				EntitySortQuery.new(@db, @tab, @map, [Queries::Order.new(expr, :desc)])
			end
			
			def each
				qry = @db.driver.select(@tab)
				@db.query(qry).each do |row|
					yield(@map.map(row))
				end
			end
			
			class CollectQuery
				def initialize(db, tab, expr, where = nil, ord = [], limit = nil, offset = nil)
					@db = db
					@tab = tab
					@where = where
					@ord = ord
					@expr = expr
					@limit = limit
					@offset = offset
				end
				
				def skip(n)
					raise('Offset already set!') if @offset != nil
					self.class.new(@db, @tab, @expr, @where, @ord, @limit, n)
				end
				
				def take(n)
					raise('Limit already set!') if @limit != nil
					self.class.new(@db, @tab, @expr, @where, @ord, n, @offset)
				end
				
				def select
					expr = yield(@expr)
					raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
					where = (@where == nil ? expr : @where.and(expr))
					SelectQuery.new(@db, @tab, @expr, where, @ord, @limit, @offset)
				end
				
				def sort
					self.class.new(@db, @tab, @expr, @where, [Queries::Order.new(@expr, :asc)], @limit, @offset)
				end
				
				def sort_desc
					self.class.new(@db, @tab, @expr, @where, [Queries::Order.new(@expr, :desc)], @limit, @offset)
				end
				
				def to_query
					@db.driver.select(@tab, @where, @ord, { :_ => @expr }, @limit, @offset)
				end
				
				def each
					@db.query(to_query).each do |row|
						yield(row['_'])
					end
				end
				
				def to_a
					ret = []
					@db.query(to_query).each do |row|
						ret << row['_']
					end
					
					ret
				end
			end
			
			class SelectQuery
				def initialize(db, tab, map, where, ord = [], limit = nil, offset = nil)
					@db = db
					@tab = tab
					@map = map
					@where = where
					@ord = ord
					@limit = limit
					@offset = offset
				end
				
				def skip(n)
					raise('Offset already set!') if @offset != nil
					self.class.new(@db, @tab, @map, @where, @ord, @limit, n)
				end
				
				def take(n)
					raise('Limit already set!') if @limit != nil
					self.class.new(@db, @tab, @map, @where, @ord, n, @offset)
				end
				
				def collect
					expr = yield(@tab.double)
					raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
					CollectQuery.new(@db, @tab, expr, @where, @ord, @limit, @offset)
				end
				
				def select
					expr = yield(@tab.double)
					raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
					self.class.new(@db, @tab, @map, @where.and(expr), @ord, @limit, @offset)
				end
				
				def to_query
					@db.driver.select(@tab, @where, @ord, nil, @limit, @offset)
				end
				
				def each
					@db.query(to_query).each do |row|
						yield(@map.map(row))
					end
				end
				
				def to_a
					ret = []
					@db.query(to_query).each do |row|
						ret << @map.map(row)
					end
					
					ret
				end
			end
			
			class EntitySortQuery
				def initialize(db, tab, map, ord, where = nil, limit = nil, offset = nil)
					@db = db
					@tab = tab
					@map = map
					@where = where
					@ord = ord
					@limit = limit
					@offset = offset
				end
				
				def skip(n)
					raise('Offset already set!') if @offset != nil
					self.class.new(@db, @tab, @expr, @where, @ord, @limit, n)
				end
				
				def take(n)
					raise('Limit already set!') if @limit != nil
					self.class.new(@db, @tab, @expr, @where, @ord, n, @offset)
				end
				
				def then_by
					expr = yield(@tab.double)
					raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
					self.class.new(@db, @tab, @map, @ord + [Queries::Order.new(expr, :asc)], @where, @limit, @offset)
				end
				
				def then_by_desc
					expr = yield(@tab.double)
					raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
					self.class.new(@db, @tab, @map, @ord + [Queries::Order.new(expr, :desc)], @where, @limit, @offset)
				end
				
				def to_query
					@db.driver.select(@tab, @where, @ord, nil, @limit, @offset)
				end
				
				def each
					@db.query(to_query).each do |row|
						yield(@map.map(row))
					end
				end
				
				def to_a
					ret = []
					@db.query(to_query).each do |row|
						ret << @map.map(row)
					end
					
					ret
				end
			end
		end
	end
end