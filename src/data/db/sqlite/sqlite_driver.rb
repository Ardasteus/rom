# Created by Matyáš Pokorný on 2019-05-13.

module ROM
	module Sqlite
		class SqliteDriver < DbDriver
			TYPES = {
				:id => DbType.new('INT'),
				:int => DbType.new('INT'),
				:string => DbType.new('NVARCHAR(MAX)')
			}
			
			def type(tp)
				TYPES[tp]
			end
			
			def initialize(itc)
				super(itc, 'Sqlite')
			end
		end
	end
end