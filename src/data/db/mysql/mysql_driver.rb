module ROM
	module MySql
		# MySQL driver for ROM ORM
		#
		# @note MySQL DB driver DOES NOT stream results sets. Instead, it pulls them whole into memory. This is due to a bug in the underlying gem.
		class MySqlDriver < SqlDriver
			# Instantiates the {ROM::MySql::MySqlDriver} class
			# @param [ROM::Interconnect] itc Registering interconnect
			def initialize(itc)
				super(itc, 'mysql', MySqlConfig)
			end
			
			# Checks whether target DB exists
			# @param [ROM::MySql::MySqlDriver::MySqlConnection] db DB connection handle
			# @return [Boolean] True if DB exists; false otherwise
			def db?(db)
				args = []
				sql = "SHOW DATABASES WHERE #{obj_name('Database')} = #{expression(Queries::ConstantValue.new(db.database), args)};"
				db.query(SqlQuery.new(sql, *args)).each do |row|
					return true
				end
				
				false
			end
			
			# Checks whether table exists in target DB
			# @param [ROM::MySql::MySqlDriver::MySqlConnection] db DB connection handle
			# @param [ROM::DbTable] tab Table to check
			# @return [Boolean] True if table exists; false otherwise
			def table?(db, tab)
				args = []
				sql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES"
				sql += " WHERE #{obj_name('table_schema')} = #{expression(Queries::ConstantValue.new(db.database), args)} AND"
				sql += " #{obj_name('table_name')} = #{expression(Queries::ConstantValue.new(tab.name), args)};"
				
				db.scalar(SqlQuery.new(sql, *args)) != 0
			end
			
			# Creates the target DB
			# @param [ROM::MySql::MySqlDriver::MySqlConnection] db DB connection handle
			def create_db(db)
				sql = "CREATE DATABASE #{obj_name(db.database)}"
				sql += " CHARACTER SET = '#{db.charset}'"
				sql += " COLLATE = '#{db.collation}';"
				
				db.execute(SqlQuery.new(sql))
				db.select_db
			end
			
			# Creates a table in the target DB
			# @param [ROM::MySql::MySqlDriver::MySqlConnection] db DB connection handle
			# @param [ROM::DbTable] tab Table to create
			def create_table(db, tab)
				args = []
				sql = "CREATE TABLE #{obj_name(db.database)}.#{obj_name(tab.name)} ("
				sql += tab.columns.reduce(nil) do |n, col|
					if n == nil
						n = ''
					else
						n += ', '
					end
					
					n += "#{obj_name(col.name)} #{col.type}"
					n += ' AUTO_INCREMENT' if tab.table.auto_properties.include?(col.mapping)
					
					n
				end
				sql += ", CONSTRAINT #{obj_name(tab.primary_key.name)} PRIMARY KEY (#{tab.primary_key.columns.collect { |i| obj_name(i.name) }.join(', ')})"
				sql += ") ENGINE = '#{db.engine}';"
				
				db.execute(SqlQuery.new(sql, *args))
			end
			
			# Creates a foreign key in the target DB
			# @param [ROM::MySql::MySqlDriver::MySqlConnection] db DB connection handle
			# @param [ROM::DbReference] ref Reference to create
			def create_foreign_key(db, ref)
				sql = "ALTER TABLE #{obj_name(db.database)}.#{obj_name(ref.from.table.name)} ADD CONSTRAINT #{obj_name(ref.name)} FOREIGN KEY"
				sql += " (#{obj_name(ref.from.name)}) REFERENCES #{obj_name(db.database)}.#{obj_name(ref.target.table.name)}(#{obj_name(ref.target.name)})"
				sql += " ON DELETE #{strategy(ref.delete_strategy)}"
				sql += " ON UPDATE #{strategy(ref.update_strategy)};"
				
				db.execute(SqlQuery.new(sql))
			end
			
			def strategy(g)
				case g
				when :cascade
					'CASCADE'
				when :null
					'SET NULL'
				when :fail
					'NO ACTION'
				when :default
					'SET DEFAULT'
				else
					raise('Unsupported foreign key strategy!')
				end
			end
			
			# Creates an index in the target DB
			# @param [ROM::MySql::MySqlDriver::MySqlConnection] db DB connection handle
			# @param [ROM::DbIndex] idx Index to create
			def create_index(db, idx)
				sql = "ALTER TABLE #{obj_name(db.database)}.#{obj_name(idx.table.name)} ADD"
				sql += " #{(idx.unique? ? 'UNIQUE ' : '')}INDEX #{obj_name(idx.name)} (#{idx.columns.collect { |i| obj_name(i.name) }.join(', ')})"
				
				db.execute(SqlQuery.new(sql))
			end
			
			# Opens a DB connection
			# @param [Object] conf Connection configuration
			# @return [ROM::MySql::MySqlDriver::MySqlConnection] Opened connection handle
			def connect(conf)
				MySqlConnection.new(self, conf)
			end
			
			# Generates SQL for given object name
			# @param [String] name Name of object to turn into SQL
			# @return [String] SQL representation of the object name
			def obj_name(name)
				"`#{name}`"
			end
			
			private :strategy
			
			# MySQL configuration model
			class MySqlConfig < Model
				property! :host, String
				property :port, Integer, 3306
				property! :user, String
				property :password, String
				property :database, String, 'romdb'
				property :charset, String, 'utf8'
				property :collation, String, 'utf8_general_ci'
				property :engine, String, 'InnoDB'
			end
			
			# MySQL connection handle
			class MySqlConnection < DbConnection
				# Gets the name of the connection
				# @return [String] Name of the connection
				def name
					'mysql'
				end
				
				# Gets the name of target DB
				# @return [String] Name of target DB
				def database
					@conf.database
				end
				
				# Gets the name of default model charset
				# @return [String] Name of default model charset
				def charset
					@conf.charset
				end
				
				# Gets the name of default model collation
				# @return [String] Name of default model collation
				def collation
					@conf.collation
				end
				
				# Gets the name of default model DB engine
				# @return [String] Name of default model DB engine
				def engine
					@conf.engine
				end
				
				# Instantiates the {ROM::MySql::MySqlDriver::MySqlConnection}
				# @param [ROM::MySql::MySqlDriver] dvr Instance of parent DB driver
				# @param [ROM::MySql::MySqlConfig] conf DB connection configuration
				def initialize(dvr, conf)
					super(dvr)
					@conf = conf
					@db = Mysql2::Client.new(:host => conf.host, :port => conf.port, :username => conf.user, :password => conf.password)
				end
				
				# Executes a DB query
				# @param [ROM::SqlQuery] q Query to execute
				# @return [ROM::DbResults] DB query results reader
				def query(q)
					puts "MYSQL: #{q.query}"
					stmt = @db.prepare(q.query)
					begin
						Results.new(stmt.execute(*q.arguments, :as => :array))
					ensure
						stmt.close
					end
				end
				
				# Ensures that the target DB is selected
				def select_db
					@db.select_db(@conf.database)
				end
				
				# Gets the ID of the last inserted row
				# @return [Object, nil] IO of the last inserted row
				def last_id
					@db.last_id
				end
				
				# Closes the DB connection
				def close
					@db.close
				end
				
				# MySql result set
				# @note Due to a bug in the underlying native gem, results are downloaded completely from DB into memory (results ARE NOT streamed)
				class Results < DbResults
					# Gets the names of returned columns
					# @return [Array<string>] Returned columns
					def columns
						@cols
					end
					
					# Instantiates the {ROM::MySql::MySqlDriver::MySqlConnection::Results} class
					# @param [Object] res MySql gem result set to read
					def initialize(res)
						if res == nil
							@cols = []
							@res = [].each
						else
							@cols = res.fields
							@res = Array.new(res.size)
							i = 0
							res.each do |r|
								@res[i] = r
								i += 1
							end
							@res = @res.each
						end
						@row = nil
					end
					
					# Fetches next record
					# @return [Boolean] True if row was fetched; false otherwise
					def next
						@row = @res.next
					rescue StopIteration
						nil
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
						# ignore
					end
				end
			end
		end
	end
end