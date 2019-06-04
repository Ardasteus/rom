module ROM
	# Represents a single column of a DB table
	class DbColumn
		# Gets the parent DB table
		# @return [ROM::DbTable] Parent table
		def table
			@tab
		end

		# Gets the column name
		# @return [String] Name of column
		def name
			@name
		end

		# Gets the column data type
		# @return [ROM::DbType] Data type of column
		def type
			@type
		end
		
		# Gets the mapped model property of the column
		# @return [ROM::ModelProperty] Mapped model property of the column
		def mapping
			@map
		end
		
		# Gets the DB reference associated with this column, if any
		# @return [ROM::DbReference, nil] Reference associated with this column
		def reference
			@ref
		end
		
		# Sets the DB reference of this column
		# @param [ROM::DbReference] ref Reference to set
		def reference=(ref)
			@ref = ref
		end

		# Instantiates the {ROM::DbColumn} class
		# @param [ROM::DbTable] tab Parent table
		# @param [String] nm Name of column
		# @param [ROM::DbType] tp Type of column
		# @param [ROM::ModelProperty] map Mapped model property of the column
		def initialize(tab, nm, tp, map)
			@tab = tab
			@name = nm
			@type = tp
			@map = map
		end
	end
end