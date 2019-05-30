# Created by Matyáš Pokorný on 2019-05-13.

module ROM
	# Specifies that a property is a reference
	class ReferenceAttribute < Attribute
		# Gets the name of the referred table
		# @return [Symbol] Name of the referred table
		def table
			@tab
		end
		
		# Gets the name of the referred column
		# @return [Symbol] Name of the referred column
		def column
			@col
		end
		
		# Instantiates the {ROM::ReferenceAttribute} class
		# @param [Symbol] tab Name of the referred table
		# @param [Symbol] col Name of the referred column
		def initialize(tab, col)
			@tab = tab
			@col = col
		end
	end
end