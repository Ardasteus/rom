module ROM
	module Queries
		# Represents an expression of a value of a function
		class FunctionExpression < QueryExpression
			# Gets the function of expression
			# @return [ROM::Queries::FunctionExpression::Function] Function, value of which is taken
			def function
				@f
			end
			
			# Gets the resulting type of the expression
			# @return [ROM::Types::Type] Resulting type of expression
			def type
				@type
			end

			# Gets the arguments of function
			# @return [Array<ROM::Queries::QueryExpression>] Expressions of function arguments
			def arguments
				@args
			end

			# Instantiates the {ROM::Queries::FunctionExpression} class
			# @param [ROM::Queries::FunctionExpression::Function] f Function to apply
			# @param [ROM::Queries::QueryExpression] args Expressions of function arguments
			def initialize(f, *args)
				@f = f
				@args = args
				@type = f.type(*args)
			end

			# Represents a pure DB function
			class Function
				# Gets the name of function
				# @return [String] Name of function
				def name
					@name
				end

				# Deduces the return type of the function
				# @param [ROM::Queries::QueryExpression] args Function arguments
				# @return [ROM::Types::Type] Resulting type of function value
				def type(*args)
					Types::Type.to_t(@type.call(*args))
				end

				# Instantiates the {ROM::Queries::FunctionExpression::Function} class
				# @param [String] nm Name of function
				# @yield [*args] Type deduction function of the function
				# @yieldparam [ROM::Queries::QueryExpression] args Function arguments
				# @yieldreturn [ROM::Types::Type] Resulting type of function value
				def initialize(nm, &block)
					@name = nm
					@type = block
				end
			end

			# COUNT aggregation function
			COUNT = Function.new('count') { Integer }
			# LOWER function
			LOWER = Function.new('lower') { String }
			# UPPER function
			UPPER = Function.new('upper') { String }
		end
	end
end