module ROM
	class DbType	
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

		def initialize(nm, tp = nil, null = false, length = nil)
			@name = nm
			@type = (tp or nm)
			@null = null
			@length = length
		end
	end
end