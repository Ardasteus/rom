module ROM
	# Represents a DB type
	class DbType
		# Gets the equivalent primitive class
		# @return [Class] Ruby equivalent class
		def primitive
			@prim
		end
		
		# Gets the name of type
		# @return [String] Name of type
		def name
			@name
		end

		# Gets the exact DB name of type
		# @return [String] DB name of type
		def type
			@type
		end

		# Determines whether type accepts NULL
		# @return [Boolean] True if type accepts NULL; false otherwise
		def nullable
			@null
		end

		# Gets the length of type
		# @return [Integer, nil] Length of type
		def length
			@length
		end

		# Instantiates the {ROM::DbType} class
		# @param [Class] prim Ruby equivalent class
		# @param [String] nm Local name
		# @param [String] tp DB type name
		# @param [Boolean] null True if type accepts NULL; false otherwise
		# @param [Integer, nil] length Length of type
		def initialize(prim, nm, tp = nil, null = false, length = nil)
			@prim = Types::Type.to_t(prim)
			@name = nm
			@type = (tp or nm)
			@null = null
			@length = length
		end
		
		# Creates a new equivalent {ROM::DbType} which doesn't accept NULL
		# @return [ROM::DbType] Equivalent, non-nullable type
		def not_null
			DbType.new(@prim, @name, @type, false, @length)
		end
		
		# Creates a new equivalent {ROM::DbType} which accepts NULL
		# @return [ROM::DbType] Equivalent, nullable type
		def null
			DbType.new(@prim, @name, @type, true, @length)
		end
		
		# Gets the string representation of the type
		# @return [String] String representation of the type
		def to_s
			"#{@type}#{(@length != nil ? "(#{@length})" : '')}#{(@null ? '' : ' NOT NULL')}"
		end
	end
end