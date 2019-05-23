module ROM
	class DbTable
		def name
			@name
		end

		def table
			@tab
		end
		
		def columns
			@cols
		end

		def indices
			@idx
		end
		
		def primary_key
			@prim
		end
		
		def double
			@dub
		end

		def initialize(nm, tab)
			@name = nm
			@tab = tab
			@cols = []
			@idx = []
			@ref = []
			@prim = nil
			@dub = Module.new
		end

		def column(nm, tp, map, *att)
			raise("Column '#{nm}' already exists in '#{@name}'!") if @cols.any? { |i| i.name == nm }
			col = DbColumn.new(self, nm, tp, map, *att)
			@cols << col
			
			val = Queries::ColumnValue.new(col)
			@dub.define_singleton_method map.name.to_sym do
			  val
			end

			col
		end
		
		def primary(nm, *cols)
			raise("Primary key already defined in '#{@name}'!") unless @prim == nil
			raise("No primary keys given for '#{@name}'!") if cols == nil or cols.length == 0
			bad = cols.find { |col| !@cols.include?(col) }
			raise("Column '#{bad.name}' is not part of table '#{@name}'!") unless bad == nil
			
			@prim = DbKey.new(self, nm, *cols)
		end

		def index(nm, uq = false, *cols)
			bad = cols.find { |col| !@cols.include?(col) }
			raise("Column '#{bad.name}' is not part of table '#{@name}'!") unless bad == nil
			@idx << DbIndex.new(self, nm, uq, *cols)
		end
	end
end