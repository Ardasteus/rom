module ROM
	# Represents a DB table
	class DbTable
		# Gets the name of table
		# @return [String] Table name
		def name
			@name
		end

		# Gets the mapped context table
		# @return [ROM::DbContext::Table] Mapped table
		def table
			@tab
		end
		
		# Gets the columns of table
		# @return [Array<ROM::DbColumn>] Table columns
		def columns
			@cols
		end

		# Gets the indices of table
		# @return [Array<ROM::DbIndex>] Table indices
		def indices
			@idx
		end
		
		# Gets the primary keys of table
		# @return [Array<ROM::DbKey>] Primary keys
		def primary_key
			@prim
		end
		
		# Gets the double of the table
		# @return [Object] A double of the table
		def double
			@dub
		end

		# Instantiates the {ROM::DbTable} class
		# @param [String] nm Name of table
		# @param [ROM::DbContext::Table] tab Mapped context table
		def initialize(nm, tab)
			@name = nm
			@tab = tab
			@cols = []
			@idx = []
			@ref = []
			@prim = nil
			@dub = Module.new
		end

		# Defines a new column
		# @param [String] nm Name of column
		# @param [ROM::DbType] tp Data type of column
		# @param [ROM::ModelProperty] map Column property mapping
		# @return [ROM::DbColumn] Newly created column
		def column(nm, tp, map)
			raise("Column '#{nm}' already exists in '#{@name}'!") if @cols.any? { |i| i.name == nm }
			col = DbColumn.new(self, nm, tp, map)
			@cols << col
			
			val = Queries::ColumnValue.new(col)
			if tp.primitive <= String
				val.define_singleton_method :include? do |other|
					raise('Expected pattern!') unless other.is_a?(String)
					Queries::LikeExpression.new(val, :any_string, other, :any_string)
				end
			end
			@dub.define_singleton_method(map.name.to_sym) { val }
			@dub.define_singleton_method(:to_s) { "TableDouble:#{nm}" }

			col
		end
		
		# Defines a primary key
		# @param [String] nm Name of primary key
		# @param [ROM::DbColumn] cols Columns of key
		# @return [ROM::DbKey] Newly created key
		def primary(nm, *cols)
			raise("Primary key already defined in '#{@name}'!") unless @prim == nil
			raise("No primary keys given for '#{@name}'!") if cols == nil or cols.length == 0
			bad = cols.find { |col| !@cols.include?(col) }
			raise("Column '#{bad.name}' is not part of table '#{@name}'!") unless bad == nil
			@prim = DbKey.new(self, nm, *cols)
		end

		# Defines a new index
		# @param [String] nm Name of index
		# @param [Boolean] uq Determines whether index is unique (true for unique; false otherwise)
		# @param [ROM::DbColumn] cols Indexed columns
		# @return [ROM::DbIndex] Newly created index
		def index(nm, uq = false, *cols)
			bad = cols.find { |col| !@cols.include?(col) }
			raise("Column '#{bad.name}' is not part of table '#{@name}'!") unless bad == nil
			idx = DbIndex.new(self, nm, uq, *cols)
			@idx << idx
			
			idx
		end
	end
end