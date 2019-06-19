module ROM
	# A surrogate for an entity to be yet lazy-loaded
	class LazyPromise
		# Gets the referring keys
		# @return [Hash{ROM::DbColumn=>[Object,nil]}] Referring keys
		def keys
			@keys
		end

		# Gets the referred table
		# @return [ROM::DbTable] Referred table
		def table
			@tab
		end

		# Gets the referred model
		# @return [ROM::Model] Referred model
		def model
			@tab.table.model
		end

		# Lazy-loads the entity
		# @return [ROM::Entity] Lazy-loaded entity
		def fetch
			@fetch.call
		end

		# Instantiates the {ROM::LazyPromise} class
		# @param [Hash{ROM::DbColumn=>[Object,nil]}] k Referring keys
		# @param [ROM::DbTable] tab Referred table
		# @yield [] Block used to {#fetch} the entity
		# @yieldreturn [ROM::Entity] Lazy-loaded entity
		def initialize(k, tab, &block)
			@keys = k
			@tab = tab
			@fetch = block
		end
	end
end