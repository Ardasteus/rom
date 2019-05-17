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
		
		def primary_keys
			@prim
		end

		def initialize(nm)
			@name = nm
			@cols = []
			@idx = []
			@ref = []
			@prim = []
		end

		def column(nm, tp, *att)
			raise("Column '#{nm}' already exists in '#{@name}'!") if @cols.any? { |i| i.name == nm }
			col = DbColumn.new(self, nm, tp, *att)
			@cols << col

			col
		end
		
		def primary(*cols)
			raise("Primary keys already defined in '#{@name}'!") if @prim.length > 0
			raise('No primary keys given!') if cols == nil or cols.length == 0
			bad = cols.find { |col| !@cols.include?(col) }
			raise("Column '#{bad.name}' is not part of table '#{@name}'!") unless bad == nil
			
			@prim = cols
		end

		def index(uq = false, *cols)
			bad = cols.find { |col| !@cols.include?(col) }
			raise("Column '#{bad.name}' is not part of table '#{@name}'!") unless bad == nil
			@idx << DbIndex.new(uq, *cols)
		end
	end
end