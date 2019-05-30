# Created by Matyáš Pokorný on 2019-05-19.

module ROM
	module Queries
		# Represents a column value expression
		class ColumnValue < QueryExpression
			# Gets the tracked column
			# @return [ROM::DbColumn] Tracked column
			def column
				@col
			end
			
			# Gets the resulting type of the expression
			# @return [ROM::Types::Type] Resulting type of expression
			def type
				Types::Type.to_t(@col.type.primitive)
			end
			
			# Instantiates the {ROM::Queries::ColumnValue} class
			# @param [ROM::DbColumn] col Column to take the value of
			def initialize(col)
				@col = col
			end

			# Creates an expression of equivalence operator for the column's value (on left) and some other expression (on right)
			# @param [ROM::Queries::QueryExpression] other Other expression to compare this column's value against
			# @return [ROM::Queries::QueryExpression] Resulting comparison expression
			def ==(other)
				if other.is_a?(Model)
					raise('Columns is not a reference source!') if @col.reference == nil
					raise("Column reference is compared to unexpected type!") unless @col.mapping.type.is(other)
					self == other[@col.reference.target.mapping.name.to_sym]
				else
					super(other)
				end
			end
			
			# Creates an expression of inequivalence operator for the column's value (on left) and some other expression (on right)
			# @param [ROM::Queries::QueryExpression] other Other expression to compare this column's value against
			# @return [ROM::Queries::QueryExpression] Resulting comparison expression
			def !=(other)
				if other.is_a?(Model)
					raise('Columns is not a reference source!') if @col.reference == nil
					raise("Column reference is compared to unexpected type!") if @col.mapping.type.is(other)
					self != other[@col.reference.target.mapping.name.to_sym]
				else
					super(other)
				end
			end
		end
	end
end