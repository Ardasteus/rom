module ROM
	# Represents a DB index
	class DbIndex
		# Gets the name of index
		# @return [String] Name of index
		def name
			@name
		end
		
		# Gets the indexed table
		# @return [ROM::DbTable] Indexed table
		def table
			@tab
		end
		
		# Determines whether index is unique
		# @return [Boolean] True if index is unique; false otherwise
		def unique?
			@unique
		end

		# Gets the indexed columns
		# @return [Array<ROM::DbColumn>] Indexed columns
		def columns
			@cols
		end

		# Instantiates the {ROM::DbIndex} class
		# @param [ROM::DbTable] tab Indexed table
		# @param [String] nm Name of index
		# @param [Boolean] unique True if index is unique; false otherwise
		# @param [ROM::DbColumn] cols Indexed columns
		def initialize(tab, nm, unique = false, *cols)
			@tab = tab
			@name = nm
			@unique = unique
			@cols = cols
		end
	end
end