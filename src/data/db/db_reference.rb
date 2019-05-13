module ROM
	class DbReference
		def from
			@from
		end

		def to
			@to
		end

		def update_strategy
			@upd
		end

		def delete_strategy
			@dlt
		end

		def initialize(src, target, upd = :cascade, dlt = :cascade)
			@from = src
			@to = target
			@upd = upd
			@dlt = dlt
		end
	end
end