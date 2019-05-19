# Created by Matyáš Pokorný on 2019-05-13.

module ROM
	module Sqlite
		class SqliteDriver < DbDriver
			TYPES = {
				Integer => DbType.new(Integer, 'INT'),
				String => DbType.new(String, 'NVARCHAR(512)'),
				Types::Boolean => DbType.new(Types::Boolean, 'BIT')
			}
			
			QUERIES = {
				:table => Proc.new { |tab|
					qry = "CREATE TABLE \"#{tab.name}\" ("
					qry += tab.columns.collect { |col| "\"#{col.name}\" #{col.type.type}#{col.type.length == nil ? '' : "(#{col.type.length})"}" }.join(', ')
					unless tab.primary_key == nil
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
			
			def create(db, schema)
				schema.tables.each do |tab|
					db.execute(query(:table, tab))
					tab.indices.each do |idx|
						db.execute(query(:index, idx.name, idx.table.name, idx.unique?, idx.columns))
					end
				end
				schema.references.each do |ref|
					# References are substituted by indices
					db.execute(query(:index, ref.name, ref.from.table.name, false, [ref.from]))
				end
			end
			
			def query(nm, *args)
				QUERIES[nm]&.call(*args)
			end
			
			def type(tp)
				TYPES[tp]
			end
			
			def initialize(itc)
				super(itc, 'Sqlite', SqliteConfig)
			end
			
			def connect(conf)
				SqliteConnection.new(SQLite3::Database.new(conf.file, { :type_translation => true }))
			end
			
			class SqliteConnection < DbConnection
				def name
					'sqlite'
				end
				
				def query(q)
					Results.new(@db.query(q.query, q.arguments))
				end
				
				def initialize(db)
					@db = db
				end
				
				def close
					@db.close
				end
				
				class Results < DbResults
					def columns
						@cols
					end
					
					def initialize(res)
						@cols = res.columns
						@res = res
						@row = nil
					end
					
					def next
						@row = @res.next
					end
					
					def [](key)
						key = key.to_s
						
						@row[@cols.index { |i| i == key }]
					end
					
					def close
						@res.close
					end
				end
			end
			
			class SqliteConfig < Model
				property! :file, String
			end
		end
	end
end