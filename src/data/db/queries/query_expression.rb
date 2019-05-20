# Created by Matyáš Pokorný on 2019-05-19.

module ROM
	module Queries
		class QueryExpression
			def type
				raise('Method not implemented!')
			end
			
			def ==(other)
				BinaryOperator.new(BinaryOperator::EQ, self, QueryExpression.to_expr(other))
			end
			
			def !=(other)
				BinaryOperator.new(BinaryOperator::NEQ, self, QueryExpression.to_expr(other))
			end
			
			def >=(other)
				BinaryOperator.new(BinaryOperator::GTI, self, QueryExpression.to_expr(other))
			end
			
			def >(other)
				BinaryOperator.new(BinaryOperator::GTE, self, QueryExpression.to_expr(other))
			end
			
			def <=(other)
				BinaryOperator.new(BinaryOperator::LTI, self, QueryExpression.to_expr(other))
			end
			
			def <(other)
				BinaryOperator.new(BinaryOperator::LTE, self, QueryExpression.to_expr(other))
			end
			
			def +(other)
				BinaryOperator.new(BinaryOperator::ADD, self, QueryExpression.to_expr(other))
			end
			
			def -(other)
				BinaryOperator.new(BinaryOperator::SUB, self, QueryExpression.to_expr(other))
			end
			
			def *(other)
				BinaryOperator.new(BinaryOperator::MUL, self, QueryExpression.to_expr(other))
			end
			
			def /(other)
				BinaryOperator.new(BinaryOperator::DIV, self, QueryExpression.to_expr(other))
			end
			
			def -@
				UnaryOperator.new(UnaryOperator::NEG, self)
			end
			
			def !
				UnaryOperator.new(UnaryOperator::NOT, self)
			end
			
			def and(other)
				BinaryOperator.new(BinaryOperator::AND, self, QueryExpression.to_expr(other))
			end
			
			def or(other)
				BinaryOperator.new(BinaryOperator::OR, self, QueryExpression.to_expr(other))
			end
			
			def self.to_expr(val)
				val.is_a?(QueryExpression) ? val : ConstantValue.new(val)
			end
		end
	end
end