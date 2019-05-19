# Created by Matyáš Pokorný on 2019-05-18.

module ROM
	class SqlDriver < DbDriver
		TYPES = {
			Integer => DbType.new(Integer, 'INT'),
			String => DbType.new(String, 'NVARCHAR(MAX)'),
			Types::Boolean => DbType.new(Types::Boolean, 'BIT')
		}
		
		def type(tp)
			TYPES[tp]
		end
		
		def initialize(itc, name, conf)
			super(itc, name, conf)
		end
	end
end