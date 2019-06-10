# Created by Matyáš Pokorný on 2019-05-18.

module ROM
	# A generic driver base for SQL-based DBs
	# @abstract
	class SqlDriver < DbDriver
		modifiers :abstract
		
		# Default types map
		TYPES = {
			String => 'NVARCHAR'
		}
		# Default map of int types based on their sizes
		INTS = {
			1 => 'TINYINT',
			2 => 'SMALLINT',
			4 => 'INT',
			8 => 'BIGINT'
		}
		
		# Resolves a type
		# @param [Class] tp Type to resolve
		# @param [Boolean] null True if type is nullable; false otherwise
		# @param [Integer, nil] len Length of the type
		# @return [ROM::DbType] Resolved DB type; nil if type couldn't be resolved
		def type(tp, null = false, len = nil)
			if tp == Integer
				int = INTS[(len or 4)]
				raise('Unsupported integer size!') if int == nil
				return DbType.new(tp, int, int, null, nil)
			end
			
			(TYPES.has_key?(tp) ? DbType.new(tp, TYPES[tp], TYPES[tp], null, len) : nil)
		end
		
		# Generates a selection query
		# @param [ROM::DbTable] from Selection source table
		# @param [ROM::Queries::QueryExpression, nil] where Filtering expression
		# @param [Array<ROM::Queries::Order>] ord Ordering rules
		# @param [Array<ROM::Queries::QueryExpression>, nil] vals Values to select; nil to select all
		# @param [Integer, nil] limit Maximal number of rows to return
		# @param [Integer, nil] offset Number of rows to skip in the result set
		# @return [ROM::SqlQuery] Generated query
		def select(from, where = nil, ord = [], vals = nil, limit = nil, offset = nil)
			args = []
			qry = "SELECT " +
				if vals == nil
					'*'
				else
					vals.collect { |kvp| "#{expression(kvp[1], args)} as #{obj_name(kvp[0].to_s)}" }.join(', ')
				end
			
			qry += " FROM #{obj_name(from.name)}"
			
			unless where.is_a?(NilClass)
				raise('WHERE requires the expression to result in boolean!') unless where.type <= Types::Boolean[]
				qry += " WHERE #{expression(where, args)}"
			end
			
			if ord.size > 0
				qry += " ORDER BY "
				qry += ord.collect { |o|
					res = expression(o.expression, args)
					res += " " + case o.order
						when :asc
							"ASC"
						when :desc
							"DESC"
					end
					
					res
				}.join(',')
			end
			
			qry += " LIMIT #{limit}" unless limit == nil
			qry += " OFFSET #{offset}" unless offset == nil
			
			SqlQuery.new(qry + ';', *args)
		end
		
		# Generates a single row insertion query
		# @param [ROM::DbTable] to Target table
		# @param [Hash{String=>ROM::Queries::QueryExpression}] values Hash of column names and their value expressions
		# @return [ROM::SqlQuery] Generated query
		def insert(to, values)
			args = []
			qry = "INSERT INTO #{obj_name(to.name)} (#{values.keys.collect(&method(:obj_name)).join(', ')}) values "
			qry += "(#{values.values.collect { |i| expression(i, args) }.join(', ')})"
			
			SqlQuery.new(qry + ';', *args)
		end
		
		# Generates an update query
		# @param [ROM::DbTable] what Table to update
		# @param [ROM::Queries::QueryExpression] where Filtering expression
		# @param [Hash{String=>ROM::Queries::QueryExpression}] with Hash of column names and their value expressions
		# @return [ROM::SqlQuery] Generated query
		def update(what, where, with)
			args = []
			qry = "UPDATE \"#{what.name}\" SET "
			qry += with.collect { |kvp| "#{obj_name(kvp[0])} = #{expression(kvp[1], args)}" }.join(', ')
			qry += " WHERE #{expression(where, args)}"
			
			SqlQuery.new(qry + ';', *args)
		end
		
		# Generates a delete query
		# @param [ROM::DbTable] from Table to delete rows from
		# @param [ROM::Queries::QueryExpression] where Filtering expression
		# @return [ROM::SqlQuery] Generated query
		def delete(from, where)
			args = []
			qry = "DELETE FROM #{obj_name(from.name)} WHERE #{expression(where, args)}"
			
			SqlQuery.new(qry + ';', *args)
		end
		
		# Translates an expression into SQL
		# @param [ROM::Queries::QueryExpression] expr Expression to translate
		# @param [Array] args Array to save the arguments to
		# @return [String] Translated SQL
		def expression(expr, args)
			case expr
				when Queries::ColumnValue
					"#{obj_name(expr.column.table.name)}.#{obj_name(expr.column.name)}"
				when Queries::ConstantValue
					args << case expr.value
						when true
							1
						when false
							0
						else
							expr.value
					end
					
					'?'
				when Queries::BinaryOperator
					if expr.operator == Queries::BinaryOperator::EQ or expr.operator == Queries::BinaryOperator::NEQ
						cmp = (expr.operator == Queries::BinaryOperator::EQ ? 'is' : 'is not')
						if expr.left.is_a?(Queries::ConstantValue) and expr.left.value == nil
							return "(#{expression(expr.right, args)} #{cmp} null)"
						elsif expr.right.is_a?(Queries::ConstantValue) and expr.right.value == nil
							return "(#{expression(expr.left, args)} #{cmp} null)"
						end
					end
					
					"(#{expression(expr.left, args)} #{expr.operator.name} #{expression(expr.right, args)})"
				when Queries::FunctionExpression
					"#{expr.function.name}(#{expr.arguments.collect { |i| expression(i, args) }.join(', ')})"
				when Queries::UnaryOperator
					"#{expr.operator.name}#{(expr.operator.name.length > 1 ? ' ' : '')}(#{expression(expr.operand, args)})"
				else
					raise('Expresion type not supported!')
			end
		end
		
		# Checks whether target DB exists
		# @param [ROM::DbConnection] db DB connection handle
		# @return [Boolean] True if DB exists; false otherwise
		def db?(db)
			raise('Method not implemented!')
		end

		# Creates the target DB
		# @param [ROM::DbConnection] db DB connection handle
		def create_db(db)
			raise('Method not implemented!')
		end
		
		# Checks whether table exists in target DB
		# @param [ROM::DbConnection] db DB connection handle
		# @param [ROM::DbTable] tab Table to check
		# @return [Boolean] True if table exists; false otherwise
		def table?(db, tab)
			raise('Method not implemented!')
		end
		
		# Creates a table in the target DB
		# @param [ROM::DbConnection] db DB connection handle
		# @param [ROM::DbTable] tab Table to create
		def create_table(db, tab)
			raise('Method not implemented!')
		end
		
		# Creates a foreign key in the target DB
		# @param [ROM::DbConnection] db DB connection handle
		# @param [ROM::DbReference] ref Reference to create
		def create_foreign_key(db, ref)
			raise('Method not implemented!')
		end
		
		# Creates an index in the target DB
		# @param [ROM::DbConnection] db DB connection handle
		# @param [ROM::DbIndex] idx Index to create
		def create_index(db, idx)
			raise('Method not implemented!')
		end
		
		# Generates SQL for given object name
		# @param [String] name Name of object to turn into SQL
		# @return [String] SQL representation of the object name
		def obj_name(name)
			name
		end
		
		# Creates the DB schema
		# @param [ROM::DbConnection] db Connection to DB
		# @param [ROM::DbSchema] schema Schema to generate
		# @return [ROM::DbStatus] Schema generation status
		def create(db, schema)
			status = DbStatus.new
			new_db = if db?(db)
				false
			else
				create_db(db)
				true
			end
			schema.tables.each do |tab|
				unless new_db or not table?(db, tab)
					status.table(tab.name.to_sym, :found)
					next
				end
				create_table(db, tab)
				status.table(tab.name.to_sym, :new)
				tab.indices.each do |idx|
					create_index(db, idx)
				end
			end
			schema.references.select { |i| status.new?(i.from.table.name.to_sym) or status.new?(i.from.table.name.to_sym) }.each do |ref|
				create_foreign_key(db, ref)
			end
			
			status
		end
		
		protected :db?, :table?, :create_db, :create_table, :create_foreign_key, :create_index, :obj_name
	end
end