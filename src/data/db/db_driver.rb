# Created by Matyáš Pokorný on 2019-05-12.

module ROM
	class DbDriver
		include Component

		def type(tp)
			raise('Method not implemented!')
		end
		
		def initialize(itc)
			@itc = itc
		end
		
		def connect(conf)
			raise('Method not implemented!')
		end
	end
end