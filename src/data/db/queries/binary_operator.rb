module ROM
	# Contains AST classes of DB queries
	module Queries
		# Represents a binary operator expression
		class BinaryOperator < QueryExpression
			# Gets the binary operator applied
			# @return [ROM::Queries::BinaryOperator::BOp] Binary operator
			def operator
				@op
			end

			# Gets the left side of operator
			# @return [ROM::Queries::QueryExpression] Left side of operator
			def left
				@left
			end
			
			# Gets the right side of operator
			# @return [ROM::Queries::QueryExpression] Right side of operator
			def right
				@right
			end
			
			# Gets the resulting type of the expression
			# @return [ROM::Types::Type] Resulting type of expression
			def type
				@type
			end

			# Instantiates the {ROM::Queries::BinaryOperator} class
			# @param [ROM::Queries::BinaryOperator::BOp] op Operator to apply
			# @param [ROM::Queries::QueryExpression] left Left side of operator
			# @param [ROM::Queries::QueryExpression] right Right side of operator
			def initialize(op, left, right)
				@op = op
				@left = left
				@right = right
				@type = op.type(left, right)
			end

			# Represents a binary operator
			class BOp
				# Gets the name of binary operator
				# @return [String] Name of operator
				def name
					@name
				end

				# Deduces the resulting type of operator
				# @param [ROM::Queries::QueryExpression] left Left side of operator
				# @param [ROM::Queries::QueryExpression] right Right side of operator
				# @return [ROM::Types::Type] Resulting type of operator
				def type(left, right)
					Types::Type.to_t(@type.call(left, right))
				end

				# Instantiates the {ROM::Queries::BinaryOperator::BOp} class
				# @param [String] nm Name of operator
				# @yield [left, right] Type deduction function of operator
				# @yieldparam [ROM::Queries::QueryExpression] left Left side of operator
				# @yieldparam [ROM::Queries::QueryExpression] right Right side of operator
				# @yieldreturn [ROM::Types::Type] Resulting type of operator
				def initialize(nm, &block)
					@name = nm
					@type = block
				end
			end

			# Type deduction function of comparison operators
			# @param [ROM::Queries::QueryExpression] left Left side of operator
			# @param [ROM::Queries::QueryExpression] right Right side of operator
			# @return [ROM::Types::Type] Resulting type of operator
			def self.cmp_op(left, right)
				unless left.type <= right.type or left.type <= NilClass or right.type <= NilClass
					raise("Types given to comparison operator don't match!")
				end
				Types::Boolean[]
			end
			
			# Type deduction function of math operators
			# @param [ROM::Queries::QueryExpression] left Left side of operator
			# @param [ROM::Queries::QueryExpression] right Right side of operator
			# @return [ROM::Types::Type] Resulting type of operator
			def self.math_op(left, right)
				raise("Types given to binary math operator don't match!") unless left.type <= right.type
				left.type
			end
			
			# Type deduction function of logical operators
			# @param [ROM::Queries::QueryExpression] left Left side of operator
			# @param [ROM::Queries::QueryExpression] right Right side of operator
			# @return [ROM::Types::Type] Resulting type of operator
			def self.logic_op(left, right)
				raise("Types of logic operator must be boolean!") unless left.type <= Types::Boolean[] and right.type <= Types::Boolean[]
				left.type
			end

			# Equivalence operator (==)
			EQ = BOp.new('=', &method(:cmp_op))
			# Inequivalence operator (!=)
			NEQ = BOp.new('!=', &method(:cmp_op))
			# Less than inclusive operator (<=)
			LTI = BOp.new('<=', &method(:cmp_op))
			# Less than exclusive operator (<)
			LTE = BOp.new('<', &method(:cmp_op))
			# Greater than inclusive operator (>=)
			GTI = BOp.new('>=', &method(:cmp_op))
			# Greater than exclusive operator (>)
			GTE = BOp.new('>', &method(:cmp_op))

			# Addition operator (+)
			ADD = BOp.new('+', &method(:math_op))
			# Subtraction operator (-)
			SUB = BOp.new('-', &method(:math_op))
			# Multiplication operator (*)
			MUL = BOp.new('*', &method(:math_op))
			# Division operator (/)
			DIV = BOp.new('/', &method(:math_op))
			
			# Conjunction operator (AND)
			AND = BOp.new('and', &method(:logic_op))
			# Inclusive disjunction operator (OR)
			OR = BOp.new('or', &method(:logic_op))
		end
	end
end