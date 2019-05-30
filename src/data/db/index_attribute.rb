# Created by Matyáš Pokorný on 2019-05-17.

module ROM
	# Declares that an index shall be built on a property
	class IndexAttribute < Attribute
		# Determines whether index should be unique
		# @return [Boolean] True if index should be unique; false otherwise
		def unique?
			@unique
		end
		
		# Instantiates the {ROM::IndexAttribute} class
		# @param [Boolean] uq True if index should be unique; false otherwise
		def initialize(uq = false)
			@unique = uq
		end
	end
end