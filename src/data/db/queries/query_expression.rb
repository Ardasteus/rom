# Created by Matyáš Pokorný on 2019-05-19.

module ROM
	module Queries
		# Base class of a query expression
		# @abstract
		class QueryExpression
			# Gets the resulting type of the expression
			# @return [ROM::Types::Type] Resulting type of expression
			def type
				raise('Method not implemented!')
			end
			
			# Combines this expression with other using the equivalence binary operator (==)
			# @param [ROM::Queries::QueryExpression] other Other expression (right side)
			# @return [ROM::Queries::QueryExpression] Resulting expression
			def ==(other)
				BinaryOperator.new(BinaryOperator::EQ, self, QueryExpression.to_expr(other))
			end
			
			# Combines this expression with other using the inequivalence binary operator (!=)
			# @param [ROM::Queries::QueryExpression] other Other expression (right side)
			# @return [ROM::Queries::QueryExpression] Resulting expression
			def !=(other)
				BinaryOperator.new(BinaryOperator::NEQ, self, QueryExpression.to_expr(other))
			end
			
			# Combines this expression with other using the greater than inclusive binary operator (>=)
			# @param [ROM::Queries::QueryExpression] other Other expression (right side)
			# @return [ROM::Queries::QueryExpression] Resulting expression
			def >=(other)
				BinaryOperator.new(BinaryOperator::GTI, self, QueryExpression.to_expr(other))
			end
			
			# Combines this expression with other using the greater than exclusive binary operator (>)
			# @param [ROM::Queries::QueryExpression] other Other expression (right side)
			# @return [ROM::Queries::QueryExpression] Resulting expression
			def >(other)
				BinaryOperator.new(BinaryOperator::GTE, self, QueryExpression.to_expr(other))
			end
			
			# Combines this expression with other using the less than inclusive binary operator (<=)
			# @param [ROM::Queries::QueryExpression] other Other expression (right side)
			# @return [ROM::Queries::QueryExpression] Resulting expression
			def <=(other)
				BinaryOperator.new(BinaryOperator::LTI, self, QueryExpression.to_expr(other))
			end
			
			# Combines this expression with other using the less than exclusive binary operator (<)
			# @param [ROM::Queries::QueryExpression] other Other expression (right side)
			# @return [ROM::Queries::QueryExpression] Resulting expression
			def <(other)
				BinaryOperator.new(BinaryOperator::LTE, self, QueryExpression.to_expr(other))
			end
			
			# Combines this expression with other using the addition binary operator (+)
			# @param [ROM::Queries::QueryExpression] other Other expression (right side)
			# @return [ROM::Queries::QueryExpression] Resulting expression
			def +(other)
				BinaryOperator.new(BinaryOperator::ADD, self, QueryExpression.to_expr(other))
			end
			
			# Combines this expression with other using the subtraction binary operator (-)
			# @param [ROM::Queries::QueryExpression] other Other expression (right side)
			# @return [ROM::Queries::QueryExpression] Resulting expression
			def -(other)
				BinaryOperator.new(BinaryOperator::SUB, self, QueryExpression.to_expr(other))
			end
			
			# Combines this expression with other using the multiplication binary operator (*)
			# @param [ROM::Queries::QueryExpression] other Other expression (right side)
			# @return [ROM::Queries::QueryExpression] Resulting expression
			def *(other)
				BinaryOperator.new(BinaryOperator::MUL, self, QueryExpression.to_expr(other))
			end
			
			# Combines this expression with other using the division binary operator (/)
			# @param [ROM::Queries::QueryExpression] other Other expression (right side)
			# @return [ROM::Queries::QueryExpression] Resulting expression
			def /(other)
				BinaryOperator.new(BinaryOperator::DIV, self, QueryExpression.to_expr(other))
			end
			
			# Gets the unary minus operator of this expression (-)
			# @return [ROM::Queries::QueryExpression] Resulting expression
			def -@
				UnaryOperator.new(UnaryOperator::NEG, self)
			end
			
			# Gets the unary NOT operator of this expression (-)
			# @return [ROM::Queries::QueryExpression] Resulting expression
			def !
				UnaryOperator.new(UnaryOperator::NOT, self)
			end
			
			# Combines this expression with other using the conjunction binary operator (AND)
			# @param [ROM::Queries::QueryExpression] other Other expression (right side)
			# @return [ROM::Queries::QueryExpression] Resulting expression
			def and(other)
				BinaryOperator.new(BinaryOperator::AND, self, QueryExpression.to_expr(other))
			end
			
			# Combines this expression with other using the inclusive disjunction binary operator (OR)
			# @param [ROM::Queries::QueryExpression] other Other expression (right side)
			# @return [ROM::Queries::QueryExpression] Resulting expression
			def or(other)
				BinaryOperator.new(BinaryOperator::OR, self, QueryExpression.to_expr(other))
			end
			
			# Converts value to an expression, unless given value is an expression
			# @param [Object] val Value to convert
			# @return [ROM::Queries::QueryExpression] Converted value
			def self.to_expr(val)
				val.is_a?(QueryExpression) ? val : ConstantValue.new(val)
			end
		end
	end
end