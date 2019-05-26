# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	class LengthAttribute < Attribute
		def length
			@len
		end
		
		def initialize(len)
			@len = len
		end
	end
end