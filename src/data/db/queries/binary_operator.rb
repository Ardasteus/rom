module ROM
	module Queries
		class BinaryOperator < QueryExpression
			def operator
				@op
			end

			def left
				@left
			end

			def right
				@right
			end

			def type
				@type
			end

			def initialize(op, left, right)
				@op = op
				@left = left
				@right = right
				@type = op.type(left, right)
			end

			class BOp
				def name
					@name
				end

				def type(left, right)
					Types::Type.to_t(@type.call(left, right))
				end

				def initialize(nm, &block)
					@name = nm
					@type = block
				end
			end

			def self.cmp_op(left, right)
				raise("Types given to comparison operator don't match!") if (left.type != right.type)
				Types::Boolean[]
			end

			def self.math_op(left, right)
				raise("Types given to binary math operator don't match!") if (left.type != right.type)
				left.type
			end

			def self.logic_op(left, right)
				raise("Types of logic operator must be boolean!") unless left.type < Types::Boolean[] and right.type < Types::Boolean[]
				left.type
			end

			EQ = BOp.new('=', &method(:cmp_op))
			NEQ = BOp.new('!=', &method(:cmp_op))
			LTI = BOp.new('<=', &method(:cmp_op))
			LTE = BOp.new('<', &method(:cmp_op))
			GTI = BOp.new('>=', &method(:cmp_op))
			GTE = BOp.new('>', &method(:cmp_op))

			ADD = BOp.new('+', &method(:math_op))
			SUB = BOp.new('-', &method(:math_op))
			MUL = BOp.new('*', &method(:math_op))
			DIV = BOp.new('/', &method(:math_op))
			
			AND = BOp.new('and', &method(:logic_op))
			OR = BOp.new('or', &method(:logic_op))
		end
	end
end