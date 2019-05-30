# Created by Matyáš Pokorný on 2019-05-13.

module ROM
	# Adds a suffix to the name of a mapped column
	class SuffixAttribute < Attribute
		# Gets the text of the suffix
		# @return [String] Text of suffix
		def suffix
			@sfx
		end
		
		# Instantiates the {ROM::SuffixAttribute} class
		# @param [String] sfx Text of suffix
		def initialize(sfx)
			@sfx = sfx
		end
	end
end