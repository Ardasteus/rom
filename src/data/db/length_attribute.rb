# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	# Declares the length of the type of a property
	class LengthAttribute < Attribute
		# Gets the length of the type
		# @return [Integer] Length of the type
		def length
			@len
		end
		
		# Instantiates the {ROM::LengthAttribute} class
		# @param [Integer] len Length of the type
		def initialize(len)
			@len = len
		end
	end
end