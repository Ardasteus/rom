module ROM
	module MySql
		class MySqlDriver < DbDriver
			TYPES = {
				:id => DbType.new('INT'),
				:int => DbType.new('INT'),
				:string => DbType.new('NVARCHAR(MAX)')
			}

			def type(tp)
				TYPES[tb]
			end

			def initialize(itc)
				super(itc)
			end
		end
	end
end