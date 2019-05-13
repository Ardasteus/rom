module ROM
	class DbColumn
		def name
			@name
		end

		def type
			@type
		end
		
		def attributes
			@att
		end

		def initialize(nm, tp, *att)
			@name = nm
			@type = tp
			@att = att
		end
	end
end