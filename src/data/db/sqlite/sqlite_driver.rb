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

					qry += ');'
					SqlQuery.new(qry)
				},
				:table? => Proc.new { |db, tab|
					qry = "SELECT count(*) FROM sqlite_master WHERE type='table' AND name=?;"

					SqlQuery.new(qry, db.name)
				},
				:fk => Proc.new { |db, ctx, ref|
					qry = "ALTER TABLE \"#{ref.source.table.name}\" ADD CONSTRAINT \""
					qry += ctx.convention(:fk_key, ref.source.table.name, ref.target.table.name, ref.terget.name, '')
					qry += "\" FOREIGN KEY (\"#{ref.source.name}\") REFERENCES \"#{ref.target.table.name}\"(\"#{ref.target.name}\")"

					SqlQuery.new(qry)
				}
			}

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