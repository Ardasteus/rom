module ROM
	class DbContext
		def schema
			@sch
		end
		
		def tables
			@tabs
		end
		
		def initialize(db, sch)
			@db = db
			@sch = sch
			@tabs = []
			
			maps = {}
			self.class.tables.each do |tab|
				t = sch.tables.find { |i| i.table == tab }
				lazy = {}
				map = { :map => EntityMapper.new(t, lazy), :lazy => lazy }
				col = TableCollection.new(@db, self, t, map[:map])
				self.class.send(:define_method, tab.name.to_sym) do
					col
				end
				@tabs << col
				maps[tab] = map
			end
			
			@sch.references.each do |ref|
				maps[ref.from.table.table][:lazy][ref.from.name.to_sym] = LazyLoader.new(@db, ref.target.table, maps[ref.target.table.table][:map])
			end
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
			end
			
			def add(mod)
				mod = mod.entity_model if mod.is_a?(Entity)
				
				row = {}
				vals = {}
				mod.class.properties.each do |prop|
					sym = prop.name.to_sym
					v = mod[sym]
					vals[sym] = v
					
					next if @tab.table.auto_properties.include?(prop)
					col = @tab.columns.find { |i| i.mapping == prop }
					
					row[col.name] = if col.reference != nil and v != nil
						raise('Models are currently not supported!') unless v.is_a?(Entity)
						Queries::ConstantValue.new(v[col.reference.target.mapping.name.to_sym])
					else
						Queries::ConstantValue.new(v)
					end
				end
				
				@db.execute(@db.driver.insert(@tab, row))
				
				if @tab.table.auto_properties.size == 1
					prop = @tab.table.auto_properties.first
					vals[prop.name.to_sym] = @db.last_id
				end
				
				Entity.new(@tab, vals)
			end
			
			def update(e)
				raise('Only entities may be updated!') unless e.is_a?(Entity)
				
				with = {}
				e.flush_changes.each_pair do |k, v|
					with[@tab.columns.find { |i| i.mapping.name.to_s == k.to_s }.name] = Queries::ConstantValue.new(v)
				end
				
				@db.execute(@db.driver.update(@tab, get_matcher(e), with))
			end
			
			def delete(e)
				raise('Only entities may be deleted!') unless e.is_a?(Entity)
				
				@db.execute(@db.driver.delete(@tab, get_matcher(e)))
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
			
			def find
				expr = yield(@tab.double)
				raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
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