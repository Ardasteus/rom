# Created by Matyáš Pokorný on 2019-05-20.

module ROM
	module Queries
		class UnaryOperator < QueryExpression
			def operand
				@expr
			end
			
			def type
				@type
			end
			
			def operator
				@op
			end
			
			def initialize(op, expr)
				@op = op
				@expr = expr
				@type = op.type(expr)
			end
			
			class UOp
				def name
					@name
				end
				
				def type(expr)
					@type.call(expr)
				end
				
				def initialize(nm, &block)
					@name = nm
					@type = block
				end
			end
			
			NEG = UOp.new('-', &:type)
			NOT = UOp.new('not') { |e| raise('Negation must take an expression of boolean type!') unless e.type < Types::Boolean[]; e.type }
		end
	end
end