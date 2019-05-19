# Created by Matyáš Pokorný on 2019-05-19.

module ROM
	module Queries
		class ConstantValue < QueryExpression
			def value
				@val
			end
			
			def type
				case @val
					when true, false
						Types::Boolean[]
					else
						Types::Just[@val.class]
				end
			end
			
			def initialize(val)
				@val = val
			end
		end
	end
end