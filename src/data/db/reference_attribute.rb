# Created by Matyáš Pokorný on 2019-05-13.

module ROM
	class ReferenceAttribute < Attribute
		def table
			@tab
		end
		
		def column
			@col
		end
		
		def initialize(tab, col)
			@tab = tab
			@col = col
		end
	end
end