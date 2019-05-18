# Created by Matyáš Pokorný on 2019-05-18.

module ROM
	class SqlDriver < DbDriver
		TYPES = {
			:id => DbType.new('INT'),
			:int => DbType.new('INT'),
			:string => DbType.new('NVARCHAR(MAX)')
		}
		
		def type(tp)
			TYPES[tp]
		end
		
		def initialize(itc, name, conf)
			super(itc, name, conf)
		end
	end
end