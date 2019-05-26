module ROM
	class DbType
		def primitive
			@prim
		end
		
		def name
			@name
		end

		def type
			@type
		end

		def nullable
			@null
		end

		def length
			@length
		end

		def initialize(prim, nm, tp = nil, null = false, length = nil)
			@prim = Types::Type.to_t(prim)
			@name = nm
			@type = (tp or nm)
			@null = null
			@length = length
		end
		
		def not_null
			DbType.new(@prim, @name, @type, false, @length)
		end
		
		def null
			DbType.new(@prim, @name, @type, true, @length)
		end
		
		def to_s
			"#{@type}#{(@length != nil ? "(#{@length})" : '')}#{(@null ? '' : ' NOT NULL')}"
		end
	end
end