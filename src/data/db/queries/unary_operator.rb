# Created by Matyáš Pokorný on 2019-05-20.

module ROM
	module Queries
		# Represents a unary operator expression
		class UnaryOperator < QueryExpression
			# Gets the operand
			# @return [ROM::Queries::QueryExpression] Operand expression
			def operand
				@expr
			end
			
			# Gets the resulting type of the expression
			# @return [ROM::Types::Type] Resulting type of expression
			def type
				@type
			end
			
			# Gets the applied operator
			# @return [ROM::Queries::UnaryOperator::UOp] Unary operator
			def operator
				@op
			end
			
			# Instantiates the {ROM::Queries::UnaryOperator} class
			# @param [ROM::Queries::UnaryExpression::UOp] op Unary operator to apply
			# @param [ROM::Queries::QueryExpresion] expr Expression to apply the operator to
			def initialize(op, expr)
				@op = op
				@expr = expr
				@type = op.type(expr)
			end
			
			# Represents a unary operator
			class UOp
				# Name of operator
				def name
					@name
				end
				
				# Deduces the resulting type of operator
				# @param [ROM::Queries::QueryExpression] expr Expression to which the operator is applied to
				# @return [ROM::Types::Type] Resulting type of operator
				def type(expr)
					@type.call(expr)
				end
				
				# Instantiates the {ROM::Queries::UnaryOperator::UOp} class
				# @param [String] nm Name of operator
				# @yield [expr] Type deduction function of operator
				# @yieldparam [ROM::Queries::QueryExpression] expr Expression to which the operator is applied to
				# @yieldreturn [ROM::Types::Type] Resulting type of operator
				def initialize(nm, &block)
					@name = nm
					@type = block
				end
			end
			
			# Arithmetical negative operator (-)
			NEG = UOp.new('-', &:type)
			# Logical negation operator (NOT)
			NOT = UOp.new('not') { |e| raise('Negation must take an expression of boolean type!') unless e.type < Types::Boolean[]; e.type }
		end
	end
end