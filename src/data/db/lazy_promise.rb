module ROM
	class LazyPromise
		def keys
			@keys
		end

		def table
			@tab
		end

		def model
			@tab.table.model
		end

		def fetch
			@fetch.call
		end

		def initialize(k, tab, &block)
			@keys = k
			@tab = tab
			@fetch = block
		end
	end
end