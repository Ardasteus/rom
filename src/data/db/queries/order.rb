module ROM
	module Queries
		# Represents an ordering rule
		class Order
			# Gets the ordering expression
			# @return [ROM::Queries::QueryExpression] The expression by which results are sorted
			def expression
				@expr
			end

			# Gets the direction of order (:asc or :desc)
			# @return [Symbol] Direction of order
			def order
				@ord
			end

			# Instantiates the {ROM::Queries::Order} class
			# @param [ROM::Queries::QueryExpression] expr The expression by which results are sorted
			# @param [Symbol] ord Direction of order (:asc or :desc)
			def initialize(expr, ord = :asc)
				@expr = expr
				@ord = ord
			end
		end
	end
end