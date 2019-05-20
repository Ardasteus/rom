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
	end
end