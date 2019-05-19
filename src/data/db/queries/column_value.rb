# Created by Matyáš Pokorný on 2019-05-19.

module ROM
	module Queries
		class ColumnValue < QueryExpression
			def column
				@col
			end
			
			def type
				@col.type.primitive
			end
			
			def initialize(col)
				@col = col
			end
		end
	end
end