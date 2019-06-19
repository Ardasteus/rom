# Created by Matyáš Pokorný on 2019-06-04.

module ROM
	class ApiException < Exception
		def initialize(msg)
			super(msg)
		end
	end
end