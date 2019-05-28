module ROM
	module MySql
		# @note MySQL DB driver DOES NOT stream results sets. Instead, it pulls them whole into memory. This is due to a bug in the underlying gem.
		class MySqlDriver < SqlDriver
			def initialize(itc)
				super(itc, 'mysql', MySqlConfig)
			end
			
			def db?(db)
				args = []
				sql = "SHOW DATABASES WHERE #{obj_name('Database')} = #{expression(Queries::ConstantValue.new(db.database), args)};"
				db.query(SqlQuery.new(sql, *args)).each do |row|
					return true
				end
				
				false
			end
			
			def table?(db, tab)
				args = []
				sql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES"
				sql += " WHERE #{obj_name('table_schema')} = #{expression(Queries::ConstantValue.new(db.database), args)} AND"
				sql += " #{obj_name('table_name')} = #{expression(Queries::ConstantValue.new(tab.name), args)};"
				
				db.scalar(SqlQuery.new(sql, *args)) != 0
			end
			
			def create_db(db)
				args = []
				sql = "CREATE DATABASE #{obj_name(db.database)}"
				sql += " CHARACTER SET = '#{db.charset}'"
				sql += " COLLATE = '#{db.collation}';"
				
				db.execute(SqlQuery.new(sql))
				db.select_db
			end
			
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
			
			def create_foreign_key(db, ref)
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
				
				sql = "ALTER TABLE #{obj_name(db.database)}.#{obj_name(ref.from.table.name)} ADD CONSTRAINT #{obj_name(ref.name)} FOREIGN KEY"
				sql += " (#{obj_name(ref.from.name)}) REFERENCES #{obj_name(db.database)}.#{obj_name(ref.target.table.name)}(#{obj_name(ref.target.name)})"
				sql += " ON DELETE #{strategy(ref.delete_strategy)}"
				sql += " ON UPDATE #{strategy(ref.update_strategy)};"
				
				db.execute(SqlQuery.new(sql))
			end
			
			def create_index(db, idx)
				sql = "ALTER TABLE #{obj_name(db.database)}.#{obj_name(idx.table.name)} ADD"
				sql += " #{(idx.unique? ? 'UNIQUE ' : '')}INDEX #{obj_name(idx.name)} (#{idx.columns.collect { |i| obj_name(i.name) }.join(', ')})"
				
				db.execute(SqlQuery.new(sql))
			end
			
			def connect(conf)
				MySqlConnection.new(self, conf)
			end
			
			def obj_name(name)
				"`#{name}`"
			end
			
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
			
			class MySqlConnection < DbConnection
				def name
					'mysql'
				end
				
				def database
					@conf.database
				end
				
				def charset
					@conf.charset
				end
				
				def collation
					@conf.collation
				end
				
				def engine
					@conf.engine
				end
				
				def initialize(dvr, conf)
					super(dvr)
					@conf = conf
					@db = Mysql2::Client.new(:host => conf.host, :port => conf.port, :username => conf.user, :password => conf.password)
				end
				
				def query(q)
					puts "MYSQL: #{q.query}"
					stmt = @db.prepare(q.query)
					begin
						Results.new(stmt.execute(*q.arguments, :as => :array))
					ensure
						stmt.close
					end
				end
				
				def select_db
					@db.select_db(@conf.database)
				end
				
				def last_id
					@db.last_id
				end
				
				def close
					@db.close
				end
				
				class Results < DbResults
					def columns
						@cols
					end
					
					def initialize(res)
						if res == nil
							@cols = []
							@res = [].each
							@row = nil
						else
							@cols = res.fields
							@res = Array.new(res.size)
							i = 0
							res.each do |r|
								@res[i] = r
								i += 1
							end
							@res = @res.each
							@row = nil
						end
					end
					
					def next
						begin
							@row = @res.next
						rescue StopIteration
							nil
						end
					end
					
					def [](key)
						key = key.to_s
						
						@row[@cols.index { |i| i == key }]
					end
					
					def close
						# ignore
					end
				end
			end
		end
	end
end