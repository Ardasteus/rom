module ROM
	class DbReference
		def name
			@name
		end
		
		def from
			@from
		end

		def target
			@tgt
		end

		def update_strategy
			@upd
		end

		def delete_strategy
			@dlt
		end

		def initialize(nm, src, target, upd = :cascade, dlt = :cascade)
			@name = nm
			@from = src
			@tgt = target
			@upd = upd
			@dlt = dlt
		end
	end
end