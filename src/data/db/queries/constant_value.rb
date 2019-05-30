# Created by Matyáš Pokorný on 2019-05-19.

module ROM
	module Queries
		# Represents an expression of constant value
		class ConstantValue < QueryExpression
			# Gets the constant value
			# @return [Object] Constant value
			def value
				@val
			end
			
			# Gets the resulting type of the expression
			# @return [ROM::Types::Type] Resulting type of expression
			def type
				case @val
					when true, false
						Types::Boolean[]
					else
						Types::Just[@val.class]
				end
			end
			
			# Instantiates the {ROM::Queries::ConstantValue} class
			# @param [Object] val Constant value
			def initialize(val)
				@val = val
			end
		end
	end
end