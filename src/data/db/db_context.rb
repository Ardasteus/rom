module ROM
	# Represents a model-based DB schema
	class DbContext
		include DbSeed
		
		# Gets the generated DB schema
		# @return [ROM::DbSchema] Flat DB schema
		def schema
			@sch
		end
		
		# Gets the associated table collections
		# @return [Array<ROM::DbContext::TableCollection>] Table collections of this context
		def tables
			@tabs.values
		end
		
		# Instantiates the {ROM::DbContext} class
		# @param [ROM::DbConnection] db DB connection handle
		# @param [ROM::DbSchema] sch Flat DB schema
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
		
		# Seeds the DB based on DB status
		# @param [ROM::DbStatus] stat DB difference status for seeding
		def seed_context(stat)
			@tabs.values.select { |i| i.table.table.model <= DbSeed and stat.new?(i.table.name.to_sym) }.each do |tab|
				tab.table.table.model.seed(tab)
			end
			
			self.class.seed(self) if stat.regenerated?
		end
		
		# Gets a table collection
		# @param [Symbol, String] key Name of table collection to get
		# @return [ROM::DbContext::TableCollection] Requested table collection
		def [](key)
			@tabs[key.to_sym]
		end
		
		# Closes the DB connection
		def close
			@db.close
		end

		# @overload self.convention(nm, args)
		# 	Defines a naming convention
		# 	@param [Symbol] nm Name of convention
		# 	@param [Object, nil] args Arguments of convention
		# 	@yield [*args] Function of convention
		# 	@yieldparam [Object, nil] args Arguments of convention computation
		# 	@yieldreturn [String] Name of object based on convention
		# @overload self.convention(nm, args)
		# 	Finds the by-convention name of an object
		# 	@param [Symbol] nm Name of convention
		# 	@param [Object, nil] args Arguments of convention computation
		# 	@return [String] By-convention name; nil if convention wasn't defined
		def self.convention(nm, *args, &block)
			if block_given?
				@conv[nm] = block
			else
				@conv[nm]&.call(*args)
			end
		end
		
		# Gets the tables defined within the context
		# @return [Array<ROM::DbContext::Table>] Defined tables
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
		
		# Defines a table
		# @param [Symbol, String] name Name of table
		# @param [Class] mod Model class of table
		# @param [Attribute] att Table attributes
		def self.table(name, mod, *att)
			name = name.to_s
			raise("Table '#{name}' already defined!") if @tabs.has_key?(name)
			@tabs[name] = Table.new(name, mod, *att)
		end
		
		# Represents a table
		class Table
			# Gets the name of the table
			# @return [String] Table name
			def name
				@name
			end
			
			# Gets the mapped model of the table
			# @return [Class] Mapped model of table
			def model
				@model
			end
			
			# Gets the attributes of the table
			# @return [Array<Attribute>] Table attributes
			def attributes
				@attributes
			end
			
			# Gets the key properties of the table
			# @return [Array<ROM::ModelProperty>] Table key properties
			def keys
				@keys
			end
			
			# Gets the auto properties of the table
			# @return [Array<ROM::ModelProperty>] Table auto-properties
			def auto_properties
				@auto
			end
			
			# Instantiates the {ROM::DbContext::Table} class
			# @param [String] nm Name of table
			# @param [Class] mod Mapped model of table
			# @param [Attribute] att Table attributes
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
		
		# A table-wide DB collection
		class TableCollection < DbCollection
			# Gets the table of the view
			# @return [ROM::DbContext::Table] Table of the view
			def table
				@tab
			end
			
			# Instantiates the {ROM::DbContext::TableCollection} class
			# @param [ROM::DbConnection] db DB connection handle
			# @param [ROM::DbContext] ctx Parent context
			# @param [ROM::DbContext::Table] tab Table of the view
			# @param [ROM::EntityMapper] map Entity mapper for the table
			def initialize(db, ctx, tab, map)
				@db = db
				@ctx = ctx
				@tab = tab
				@map = map
				@type = tab.table.model
			end
			
			# Adds a model to the table
			# @param [ROM::Model] entities Models to add
			# @option opt [Boolean] :deep When set to true, model is added recursively (dependencies-first)
			# @return [ROM::Entity, Array<ROM::Entity>] Added entities
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
			
			# Updates entities in the DB
			# @param [ROM::Entity] entities Entities to update
			# @option opt [Boolean] :deep When set to true, entity is updated (or added) recursively (dependencies-first)
			# @option opt [Boolean] :full When set to true, even dependencies in properties that were not changed, will be recursively scanned for changes
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
			
			# @overload delete()
			# 	Deletes all entities that match a given expression
			# 	@yield [tab] Filter builder function
			# 	@yieldparam [Object] tab Double of a table
			# 	@yieldreturn [ROM::Queries::QueryExpression] Filtering expression
			# @overload delete(e)
			# 	Deletes given entity from the DB
			# 	@param [ROM::Entity] e Entity to delete
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
			
			# Alias for {#add} (with recursion)
			# @param [ROM::Model] e Model to add
			# @return [ROM::Entity] Added entity
			def <<(e)
				add(e)
			end
			
			# Filters only entities that match given expression
			# @yield [tab] Filter builder function
			# @yieldparam [Object] tab Double of a table
			# @yieldreturn [ROM::Queries::QueryExpression] Filtering expression
			# @return [ROM::DbContext::TableCollection::SelectQuery] Filtered query
			def select
				expr = yield(@tab.double)
				raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
				SelectQuery.new(@db, @tab, @map, expr)
			end
			
			# Reduces each entity into a single scalar value
			# @yield [tab] Expression builder function
			# @yieldparam [Object] tab Double of a table
			# @yieldreturn [ROM::Queries::QueryExpression] Reducing expression
			# @return [ROM::DbContext::TableCollection::CollectQuery] Reduced query
			def collect
				expr = yield(@tab.double)
				raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
				CollectQuery.new(@db, @tab, expr)
			end
			
			# @overload find()
			# 	Finds a single entity that matched given expression
			# 	@yield [tab] Matcher builder function
			# 	@yieldparam [Object] tab Double of a table
			# 	@yieldreturn [ROM::Queries::QueryExpression] Matching expression
			# 	@return [Entity, nil] Found entity; nil otherwise
			# @overload find(*keys)
			# 	Finds a single entity of provided keys (in order of appearance in model)
			# 	@param [Object, nil] keys Key values
			# 	@return [Entity, nil] Found entity; nil otherwise
			# @overload find(**named_keys)
			# 	Finds a single entity of provided keys
			# 	@param [Object, nil] named_keys Key values
			# 	@return [Entity, nil] Found entity; nil otherwise
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
			
			# Sorts (in ascending order) resulting set based on given expression
			# @yield [tab] Expression builder function
			# @yieldparam [Object] tab Double of a table
			# @yieldreturn [ROM::Queries::QueryExpression] Sorting value expression
			# @return [ROM::DbContext::TableCollection::EntitySortQuery] Sorted query
			def sort_by
				expr = yield(@tab.double)
				raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
				EntitySortQuery.new(@db, @tab, @map, [Queries::Order.new(expr, :asc)])
			end
			
			# Sorts (in descending order) resulting set based on given expression
			# @yield [tab] Expression builder function
			# @yieldparam [Object] tab Double of a table
			# @yieldreturn [ROM::Queries::QueryExpression] Sorting value expression
			# @return [ROM::DbContext::TableCollection::EntitySortQuery] Sorted query
			def sort_by_desc
				expr = yield(@tab.double)
				raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
				EntitySortQuery.new(@db, @tab, @map, [Queries::Order.new(expr, :desc)])
			end
			
			# Enumerates all entities
			# @yield [e] Block to execute for each entity
			# @yieldparam [Entity] e Fetched entity
			def each
				qry = @db.driver.select(@tab)
				@db.query(qry).each do |row|
					yield(@map.map(row))
				end
			end
			
			private :add_recursive, :update_recursive, :get_matcher
			
			# Represents a reduced query
			class CollectQuery
				# Instantiates the {ROM::DbContext::TableCollection::CollectQuery} class
				# @param [ROM::DbConnection] db DB connection handle
				# @param [ROM::DbTable] tab Table to query from
				# @param [ROM::Queries::QueryExpression] expr Value expression
				# @param [ROM::Queries::QueryExpression, nil] where Filtering expression
				# @param [Array<ROM::Queries::Order>] ord Ordering rules
				# @param [Integer, nil] limit Maximal number of results
				# @param [Integer, nil] offset Number of results skipped in the result set
				def initialize(db, tab, expr, where = nil, ord = [], limit = nil, offset = nil)
					@db = db
					@tab = tab
					@where = where
					@ord = ord
					@expr = expr
					@limit = limit
					@offset = offset
				end
				
				# Skips the given number of results
				# @param [Integer] n Number of results to skip
				# @return [ROM::DbContext::TableCollection::CollectQuery] Offset query
				def skip(n)
					raise('Offset already set!') if @offset != nil
					self.class.new(@db, @tab, @expr, @where, @ord, @limit, n)
				end
				
				# Limits the number of results
				# @param [Integer] n Maximal number of returned results
				# @return [ROM::DbContext::TableCollection::CollectQuery] Limited query
				def take(n)
					raise('Limit already set!') if @limit != nil
					self.class.new(@db, @tab, @expr, @where, @ord, n, @offset)
				end
				
				# Filters only values that match given expression
				# @yield [v] Filter builder function
				# @yieldparam [Object] v Reduced value to filter
				# @yieldreturn [ROM::Queries::QueryExpression] Filtering expression
				# @return [ROM::DbContext::TableCollection::SelectQuery] Filtered query
				def select
					expr = yield(@expr)
					raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
					where = (@where == nil ? expr : @where.and(expr))
					SelectQuery.new(@db, @tab, @expr, where, @ord, @limit, @offset)
				end
				
				# Sorts (in ascending order) by a value
				# @return [ROM::DbContext::TableCollection::EntitySortQuery] Sorted query
				def sort
					self.class.new(@db, @tab, @expr, @where, [Queries::Order.new(@expr, :asc)], @limit, @offset)
				end
				
				# Sorts (in descending order) by a value
				# @return [ROM::DbContext::TableCollection::EntitySortQuery] Sorted query
				def sort_desc
					self.class.new(@db, @tab, @expr, @where, [Queries::Order.new(@expr, :desc)], @limit, @offset)
				end
				
				# Executes the query
				# @return [ROM::DbResults] Query result set
				def to_query
					@db.driver.select(@tab, @where, @ord, { :_ => @expr }, @limit, @offset)
				end
				
				# Enumerates through the query results
				# @yield [v] Block of enumeration
				# @yieldparam [Object, nil] v Value of returned result set
				def each
					@db.query(to_query).each do |row|
						yield(row['_'])
					end
				end
				
				# Queries the results set as an array
				# @return [Array<[Object, nil]>] Returned results
				def to_a
					ret = []
					@db.query(to_query).each do |row|
						ret << row['_']
					end
					
					ret
				end
			end
			
			# Represents a filtered query
			class SelectQuery
				# Instantiates the {ROM::DbContext::TableCollection::SelectQuery} class
				# @param [ROM::DbConnection] db DB connection handle
				# @param [ROM::DbTable] tab Table to query from
				# @param [ROM::EntityMapper] map Result set entity mapper
				# @param [ROM::Queries::QueryExpression, nil] where Filtering expression
				# @param [Array<ROM::Queries::Order>] ord Ordering rules
				# @param [Integer, nil] limit Maximal number of results
				# @param [Integer, nil] offset Number of results skipped in the result set
				def initialize(db, tab, map, where, ord = [], limit = nil, offset = nil)
					@db = db
					@tab = tab
					@map = map
					@where = where
					@ord = ord
					@limit = limit
					@offset = offset
				end
				
				# Skips the given number of results
				# @param [Integer] n Number of results to skip
				# @return [ROM::DbContext::TableCollection::SelectQuery] Offset query
				def skip(n)
					raise('Offset already set!') if @offset != nil
					self.class.new(@db, @tab, @map, @where, @ord, @limit, n)
				end
				
				# Limits the number of results
				# @param [Integer] n Maximal number of returned results
				# @return [ROM::DbContext::TableCollection::SelectQuery] Limited query
				def take(n)
					raise('Limit already set!') if @limit != nil
					self.class.new(@db, @tab, @map, @where, @ord, n, @offset)
				end
				
				# Reduces each entity into a single scalar value
				# @yield [tab] Expression builder function
				# @yieldparam [Object] tab Double of a table
				# @yieldreturn [ROM::Queries::QueryExpression] Reducing expression
				# @return [ROM::DbContext::TableCollection::CollectQuery] Reduced query
				def collect
					expr = yield(@tab.double)
					raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
					CollectQuery.new(@db, @tab, expr, @where, @ord, @limit, @offset)
				end
				
				# Filters only entities that match given expression
				# @yield [tab] Filter builder function
				# @yieldparam [Object] tab Double of a table
				# @yieldreturn [ROM::Queries::QueryExpression] Filtering expression
				# @return [ROM::DbContext::TableCollection::SelectQuery] Filtered query
				def select
					expr = yield(@tab.double)
					raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
					self.class.new(@db, @tab, @map, @where.and(expr), @ord, @limit, @offset)
				end
				
				# Executes the query
				# @return [ROM::DbResults] Query result set
				def to_query
					@db.driver.select(@tab, @where, @ord, nil, @limit, @offset)
				end
				
				# Enumerates through the query results
				# @yield [e] Block of enumeration
				# @yieldparam [Object, nil] e Entity of returned result set
				def each
					@db.query(to_query).each do |row|
						yield(@map.map(row))
					end
				end
				
				# Queries the results set as an array
				# @return [Array<Entity>] Returned entities
				def to_a
					ret = []
					@db.query(to_query).each do |row|
						ret << @map.map(row)
					end
					
					ret
				end
			end
			
			# Represents an ordered query
			class EntitySortQuery
				# Instantiates the {ROM::DbContext::TableCollection::EntitySortQuery} class
				# @param [ROM::DbConnection] db DB connection handle
				# @param [ROM::DbTable] tab Table to query from
				# @param [ROM::EntityMapper] map Result set entity mapper
				# @param [Array<ROM::Queries::Order>] ord Ordering rules
				# @param [ROM::Queries::QueryExpression, nil] where Filtering expression
				# @param [Integer, nil] limit Maximal number of results
				# @param [Integer, nil] offset Number of results skipped in the result set
				def initialize(db, tab, map, ord, where = nil, limit = nil, offset = nil)
					@db = db
					@tab = tab
					@map = map
					@where = where
					@ord = ord
					@limit = limit
					@offset = offset
				end
				
				# Skips the given number of results
				# @param [Integer] n Number of results to skip
				# @return [ROM::DbContext::TableCollection::SelectQuery] Offset query
				def skip(n)
					raise('Offset already set!') if @offset != nil
					self.class.new(@db, @tab, @expr, @where, @ord, @limit, n)
				end
				
				# Limits the number of results
				# @param [Integer] n Maximal number of returned results
				# @return [ROM::DbContext::TableCollection::SelectQuery] Limited query
				def take(n)
					raise('Limit already set!') if @limit != nil
					self.class.new(@db, @tab, @expr, @where, @ord, n, @offset)
				end
				
				# Sorts (in ascending order) by another value
				# @return [ROM::DbContext::TableCollection::EntitySortQuery] Sorted query
				def then_by
					expr = yield(@tab.double)
					raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
					self.class.new(@db, @tab, @map, @ord + [Queries::Order.new(expr, :asc)], @where, @limit, @offset)
				end
				
				# Sorts (in descending order) by another value
				# @return [ROM::DbContext::TableCollection::EntitySortQuery] Sorted query
				def then_by_desc
					expr = yield(@tab.double)
					raise('Block must result in expression!') unless expr.is_a?(Queries::QueryExpression)
					self.class.new(@db, @tab, @map, @ord + [Queries::Order.new(expr, :desc)], @where, @limit, @offset)
				end
				
				# Executes the query
				# @return [ROM::DbResults] Query result set
				def to_query
					@db.driver.select(@tab, @where, @ord, nil, @limit, @offset)
				end
				
				# Enumerates through the query results
				# @yield [e] Block of enumeration
				# @yieldparam [Object, nil] e Entity of returned result set
				def each
					@db.query(to_query).each do |row|
						yield(@map.map(row))
					end
				end
				
				# Queries the results set as an array
				# @return [Array<Entity>] Returned entities
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