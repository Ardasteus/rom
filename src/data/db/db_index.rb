module ROM
	class DbIndex
		def name
			@name
		end
		
		def table
			@tab
		end
		
		def unique?
			@unique
		end

		def columns
			@cols
		end

		def initialize(tab, nm, unique = false, *cols)
			@tab = tab
			@name = nm
			@unique = unique
			@cols = cols
		end
	end
end