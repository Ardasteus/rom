# Created by Matyáš Pokorný on 2019-05-13.

module ROM
	module Sqlite
		# DB driver for SQLite
		class SqliteDriver < DbDriver
			
			# Mapping table of types
			TYPES = {
				Integer => 'INTEGER',
				String => 'NVARCHAR'
			}
			# Query builders
			QUERIES = {
				:table => Proc.new { |tab|
					qry = "CREATE TABLE \"#{tab.name}\" ("
					pk_exp = (tab.primary_key != nil and tab.primary_key.columns.size == 1 ? tab.primary_key.columns.first : nil)
					qry += tab.columns.collect { |col| "\"#{col.name}\" #{col.type}#{(pk_exp == col ? ' PRIMARY KEY' : '')}" }.join(', ')
					unless tab.primary_key == nil or pk_exp != nil
						qry += ", PRIMARY KEY (#{tab.primary_key.columns.collect { |i| "\"#{i.name}\"" }.join(', ')})"
					end
					qry += ');'
					SqlQuery.new(qry)
				},
				:table? => Proc.new { |tab|
					SqlQuery.new("SELECT count(*) FROM sqlite_master WHERE type='table' AND name=?;", tab.name)
				},
				:index => Proc.new { |name, tab, uq, cols|
					SqlQuery.new("CREATE#{uq ? ' UNIQUE' : ''} INDEX \"#{name}\" ON \"#{tab}\"(#{cols.collect { |i| "\"#{i.name}\"" }.join(', ')})")
				}
			}
			
			# Creates the DB schema
			# @param [ROM::DbConnection] db Connection to DB
			# @param [ROM::DbSchema] schema Schema to generate
			# @return [ROM::DbStatus] Schema generation status
			def create(db, schema)
				status = DbStatus.new
				schema.tables.each do |tab|
					unless db.scalar(query(:table?, tab)) == 0
						status.table(tab.name.to_sym, :found)
						next
					end
					db.execute(query(:table, tab))
					status.table(tab.name.to_sym, :new)
					tab.indices.each do |idx|
						db.execute(query(:index, idx.name, idx.table.name, idx.unique?, idx.columns))
					end
				end
				schema.references.select { |i| status.new?(i.from.table.name.to_sym) or status.new?(i.from.table.name.to_sym) }.each do |ref|
					# References are substituted by indices
					db.execute(query(:index, ref.name, ref.from.table.name, false, [ref.from]))
				end
				
				status
			end
			
			# Generates a query using a builder
			# @param [String] nm Name of builder
			# @param [Object] args Builder arguments
			# @return [ROM::SqlQuery] Built query
			def query(nm, *args)
				QUERIES[nm]&.call(*args)
			end
			
			# Generates a single row insertion query
			# @param [ROM::DbTable] to Target table
			# @param [Hash{String=>ROM::Queries::QueryExpression}] values Hash of column names and their value expressions
			# @return [ROM::SqlQuery] Generated query
			def insert(to, values)
				args = []
				qry = "INSERT INTO \"#{to.name}\" (#{values.keys.collect { |i| "\"#{i}\"" }.join(', ')}) values "
				qry += "(#{values.values.collect { |i| expression(i, args) }.join(', ')})"
				
				SqlQuery.new(qry, *args)
			end
			
			# Generates an update query
			# @param [ROM::DbTable] what Table to update
			# @param [ROM::Queries::QueryExpression] where Filtering expression
			# @param [Hash{String=>ROM::Queries::QueryExpression}] with Hash of column names and their value expressions
			# @return [ROM::SqlQuery] Generated query
			def update(what, where, with)
				args = []
				qry = "UPDATE \"#{what.name}\" SET "
				qry += with.collect { |kvp| "\"#{kvp[0]}\" = #{expression(kvp[1], args)}" }.join(', ')
				qry += " WHERE #{expression(where, args)}"
				
				SqlQuery.new(qry, *args)
			end
			
			# Generates a delete query
			# @param [ROM::DbTable] from Table to delete rows from
			# @param [ROM::Queries::QueryExpression] where Filtering expression
			# @return [ROM::SqlQuery] Generated query
			def delete(from, where)
				args = []
				qry = "DELETE FROM \"#{from.name}\" WHERE #{expression(where, args)}"
				
				SqlQuery.new(qry, *args)
			end
			
			# Generates a selection query
			# @param [ROM::DbTable] from Selection source table
			# @param [ROM::Queries::QueryExpression, nil] where Filtering expression
			# @param [Array<ROM::Queries::Order>] ord Ordering rules
			# @param [Array<ROM::Queries::QueryExpression>, nil] vals Values to select; nil to select all
			# @param [Integer, nil] limit Maximal number of rows to return
			# @param [Integer, nil] offset Number of rows to skip in the result set
			# @return [ROM::SqlQuery] Generated query
			def select(from, where = nil, ord = [], vals = nil, limit = nil, offset = nil)
				args = []
				qry = "SELECT " +
					if vals == nil
						'*'
					else
						vals.collect { |kvp| "#{expression(kvp[1], args)} as \"#{kvp[0].to_s}\"" }.join(', ')
					end
				
				qry += " FROM \"#{from.name}\""
				
				unless where.is_a?(NilClass)
					raise('WHERE requires the expression to result in boolean!') unless where.type <= Types::Boolean[]
					qry += " WHERE #{expression(where, args)}"
				end
				
				if ord.size > 0
					qry += " ORDER BY "
					qry += ord.collect { |o|
						res = expression(o.expression, args)
						res += " " + case o.order
							when :asc
								"ASC"
							when :desc
								"DESC"
						end
						
						res
					}.join(',')
				end
				
				qry += " LIMIT #{limit}" unless limit == nil
				qry += " OFFSET #{offset}" unless offset == nil
				
				SqlQuery.new(qry, *args)
			end
			
			# Translates an expression into SQL
			# @param [ROM::Queries::QueryExpression] expr Expression to translate
			# @param [Array] args Array to save the arguments to
			# @return [String] Translated SQL
			def expression(expr, args)
				case expr
					when Queries::ColumnValue
						"\"#{expr.column.table.name}\".\"#{expr.column.name}\""
					when Queries::ConstantValue
						args << case expr.value
							when true
								1
							when false
								0
							else
								expr.value
						end
						
						'?'
					when Queries::BinaryOperator
						if expr.operator == Queries::BinaryOperator::EQ or expr.operator == Queries::BinaryOperator::NEQ
							cmp = (expr.operator == Queries::BinaryOperator::EQ ? 'is' : 'is not')
							if expr.left.is_a?(Queries::ConstantValue) and expr.left.value == nil
								return "(#{expression(expr.right, args)} #{cmp} null)"
							elsif expr.right.is_a?(Queries::ConstantValue) and expr.right.value == nil
								return "(#{expression(expr.left, args)} #{cmp} null)"
							end
						end
						
						"(#{expression(expr.left, args)} #{expr.operator.name} #{expression(expr.right, args)})"
					when Queries::FunctionExpression
						"#{expr.function.name}(#{expr.arguments.collect { |i| expression(i, args) }.join(', ')})"
					when Queries::UnaryOperator
						"#{expr.operator.name}#{(expr.operator.name.length > 1 ? ' ' : '')}(#{expression(expr.operand, args)})"
					else
						raise('Expresion type not supported!')
				end
			end
			
			# Resolves a type
			# @param [Class] tp Type to resolve
			# @param [Boolean] null True if type is nullable; false otherwise
			# @param [Integer, nil] len Length of the type
			# @return [ROM::DbType] Resolved DB type; nil if type couldn't be resolved
			def type(tp, null = false, len = nil)
				len = nil if tp == Integer and len != nil
				(TYPES.has_key?(tp) ? DbType.new(tp, TYPES[tp], TYPES[tp], null, len) : nil)
			end
			
			# Instantiates the {ROM::Sqlite::SqliteDriver} class
			# @param [ROM::Interconnect] itc Registering interconnect
			def initialize(itc)
				super(itc, 'sqlite', SqliteConfig)
				@cid = 0
			end
			
			# Opens a DB connection
			# @param [Object] conf Connection configuration
			# @return [ROM::DbConnection] Opened connection handle
			def connect(conf)
				fs = @itc.fetch(Filesystem)
				@cid += 1
				SqliteConnection.new(self, @cid, fs.path(conf.file).expand_path.to_s)
			end
			
			# Handles connection to an SQLite DB
			class SqliteConnection < DbConnection
				# Gets the name of the connection
				# @return [String] Name of the connection
				def name
					'sqlite'
				end
				
				# Executes a DB query
				# @param [ROM::SqlQuery] q Query to execute
				# @return [ROM::DbResults] DB query results reader
				def query(q)
					Results.new(@db.query(q.query, q.arguments))
				end
				
				# Instantiates the {ROM::DbConnection} class
				# @param [ROM::DbDriver] dvr Driver that manages the connection
				# @param [String] file SQLite file to connect to
				def initialize(dvr, cid, file)
					super(dvr)
					@db = SQLite3::Database.new(file, { :type_translation => true })
					@cid = cid
					@state = :open
				end
				
				# Gets the ID of the last inserted row
				# @return [Object, nil] IO of the last inserted row
				def last_id
					scalar(SqlQuery.new("SELECT last_insert_rowid()"))
				end
				
				# Ensures that the target DB is selected
				def select_db
					# ignored
				end
				
				# Closes the DB connection
				def close
					@db.close
					@state = :closed
				end
				
				# SQLite query result set
				class Results < DbResults
					# Gets the names of returned columns
					# @return [Array<string>] Returned columns
					def columns
						@cols
					end
					
					# Instantiates the {ROM::Sqlite::SqliteDriver::SqliteConnection::Results} class
					# @param [Object] res SQLite query gem result set
					def initialize(res)
						@cols = res.columns
						@res = res
						@row = nil
					end
					
					# Fetches next record
					# @return [Boolean] True if row was fetched; false otherwise
					def next
						@row = @res.next
					end
					
					# Gets the value of column on current row
					# @param [String] key Column to fetch
					# @return [Object, nil] Value in the given column on current row
					def [](key)
						key = key.to_s
						
						@row[@cols.index { |i| i == key }]
					end
					
					# Closes the reader
					def close
						@res.close
					end
				end
			end
			
			# Model of SQLite connection configuration
			class SqliteConfig < Model
				property! :file, String
			end
		end
	end
end