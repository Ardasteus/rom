module ROM
	class DbIndex
		def unique?
			@unq
		end

		def columns
			@cols = cols
		end

		def initialize(unique = false, *cols)
			@unq = unique
			@cols = cols
		end
	end
end