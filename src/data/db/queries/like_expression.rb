# Created by Matyáš Pokorný on 2019-06-12.

module ROM
	module Queries
		class LikeExpression < QueryExpression
			# Gets the resulting type of the expression
			# @return [ROM::Types::Type] Resulting type of expression
			def type
				Types::Boolean[]
			end
			
			def expression
				@expr
			end
			
			def segments
				@seg
			end
			
			def initialize(expr, *seg)
				raise('Expression for LIKE must result in string!') unless expr.type <= String
				@expr = expr
				@seg = seg.collect do |i|
					case i
						when :any_char, :any_string
							{ :type => i }
						when String
							{ :type => :string, :value => i }
						else
							raise(Exception.new("Invalid LIKE segment!: #{i}"))
					end
				end
			end
		end
	end
end