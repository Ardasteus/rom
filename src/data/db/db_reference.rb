module ROM
	class DbReference
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

		def initialize(src, target, upd = :cascade, dlt = :cascade)
			@from = src
			@tgt = target
			@upd = upd
			@dlt = dlt
		end
	end
end