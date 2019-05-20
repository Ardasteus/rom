module ROM
	module Queries
		class Order
			def expression
				@expr
			end

			def order
				@ord
			end

			def initialize(expr, ord = :asc)
				@expr = expr
				@ord = ord
			end
		end
	end
end