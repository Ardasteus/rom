module ROM
	module MySql
		class MySqlDriver < SqlDriver
			TYPES = {
				Integer => DbType.new(Integer, 'INT'),
				String => DbType.new(String, 'NVARCHAR(MAX)'),
				Types::Boolean => DbType.new(Types::Boolean, 'BIT')
			}

			def type(tp)
				TYPES[tp]
			end

			def initialize(itc)
				super(itc, 'MySQL', MySqlConfig)
			end
			
			def create(db, schema)
			
			end
			
			class MySqlConfig < Model
				property! :host, String
				property :port, Integer, 3066
				property! :user, String
				property :password, String
				property :database, String, 'romdb'
			end
		end
	end
end