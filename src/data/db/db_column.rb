module ROM
	class DbColumn
		def name
			@name
		end

		def type
			@type
		end

		def initialize(nm, tp)
			@name = nm
			@type = tp
		end
	end
end