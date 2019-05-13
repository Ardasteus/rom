# Created by Matyáš Pokorný on 2019-05-13.

module ROM
	class SuffixAttribute < Attribute
		def suffix
			@sfx
		end
		
		def initialize(sfx)
			@sfx = sfx
		end
	end
end