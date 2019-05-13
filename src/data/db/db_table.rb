module ROM
	class DbTable
		def name
			@name
		end

		def columns
			@cols
		end

		def indices
			@idx
		end

		def initialize(nm)
			@name = nm
			@cols = []
			@idx = []
		end

		def column(nm, tp)
			col = DbColumn.new(nm, tp)
			@cols << col

			col
		end

		def index(uq = false, *cols)
			bad = cols.collect.find { |col| !@cols.include?(col) }
			raise("Column '#{bad.name}' is not part of this table!") unless bad == nil
			@idx << DbIndex.new(uq, *cols)
		end
	end
end