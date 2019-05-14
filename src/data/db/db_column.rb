module ROM
	class DbColumn
		def table
			@tab
		end

		def name
			@name
		end

		def type
			@type
		end
		
		def attributes
			@att
		end

		def initialize(tab, nm, tp, *att)
			@table = tab
			@name = nm
			@type = tp
			@att = att
		end
	end
end