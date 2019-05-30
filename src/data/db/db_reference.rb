module ROM
	# Represents a DB reference
	class DbReference
		# Gets the name of reference
		# @return [String] Name of reference
		def name
			@name
		end
		
		# Gets the referencing column
		# @return [ROM::DbColumn] Referencing column
		def from
			@from
		end
		
		# Gets the referenced column
		# @return [ROM::DbColumn] Referenced column
		def target
			@tgt
		end

		# Gets the reference update strategy (:cascade, :null, :fail, :default)
		# @return [Symbol] Update strategy
		def update_strategy
			@upd
		end
		
		# Gets the reference delete strategy (:cascade, :null, :fail, :default)
		# @return [Symbol] Delete strategy
		def delete_strategy
			@dlt
		end

		# Instantiates the {ROM::DbReference} class
		# @param [String] nm Name of reference
		# @param [ROM::DbColumn] src Referencing column
		# @param [ROM::DbColumn] target Referenced column
		# @param [Symbol] upd Update strategy
		# @param [Symbol] dlt Delete strategy
		def initialize(nm, src, target, upd = :cascade, dlt = :cascade)
			@name = nm
			@from = src
			@tgt = target
			@upd = upd
			@dlt = dlt
		end
	end
end