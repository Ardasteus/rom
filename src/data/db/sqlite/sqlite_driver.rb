# Created by Matyáš Pokorný on 2019-05-13.

module ROM
	module Sqlite
		class SqliteDriver < DbDriver
			TYPES = {
				:id => DbType.new('INT'),
				:int => DbType.new('INT'),
				:string => DbType.new('NVARCHAR(MAX)')
			}

			QUERIES = {
				:table => Proc.new { |db, tab| 
					qry = "CREATE TABLE \"#{tab.name}\" ("
					qry += tab.columns.collect { |col| "\"#{col.name}\" #{col.type.type}#{col.type.length == nil ? '' : "(#{col.type.length})"}" }.join(', ')
					if tab.primary_keys.size > 0
						qry += ", PRIMARY KEY (#{tab.primary_keys.collect { |i| "\"#{i.name}\"" }.join(', ')})"
					end
					qry += ');'
					SqlQuery.new(qry)
				},
				:table? => Proc.new { |db, tab|
					qry = "SELECT count(*) FROM sqlite_master WHERE type='table' AND name=?;"

					SqlQuery.new(qry, db.name)
				}
			}

			def create(ctx, db, schema)
				schema.tables.each do |tab|
					puts query(:table, db, tab).query
				end
			end

			def query(nm, *args)
				QUERIES[nm]&.call(*args)
			end
			
			def type(tp)
				TYPES[tp]
			end
			
			def initialize(itc)
				super(itc, 'Sqlite')
			end
		end
	end
end