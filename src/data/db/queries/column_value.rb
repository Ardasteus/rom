# Created by Matyáš Pokorný on 2019-05-19.

module ROM
	module Queries
		class ColumnValue < QueryExpression
			def column
				@col
			end
			
			def type
				Types::Type.to_t(@col.type.primitive)
			end
			
			def initialize(col)
				@col = col
			end

			def ==(other)
				if other.is_a?(Model)
					raise('Columns is not a reference source!') if @col.reference == nil
					puts @col.mapping.type.inspect
					raise("Column reference is compared to unexpected type!") if @col.mapping.type.is(other)
					self == other[@col.reference.target.mapping.name.to_sym]
				else
					super(other)
				end
			end

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