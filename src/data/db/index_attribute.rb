# Created by Matyáš Pokorný on 2019-05-17.

module ROM
	class IndexAttribute < Attribute
		def unique?
			@unique
		end
		
		def initialize(uq = false)
			@unique = uq
		end
	end
end