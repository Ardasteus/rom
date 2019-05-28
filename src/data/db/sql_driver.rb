# Created by Matyáš Pokorný on 2019-05-18.

module ROM
	class SqlDriver < DbDriver
		TYPES = {
			String => 'NVARCHAR',
			Types::Boolean => 'TINYINT'
		}
		INTS = {
			1 => 'TINYINT',
			2 => 'SMALLINT',
			4 => 'INT',
			8 => 'BIGINT'
		}
		
		def type(tp, null = false, len = nil)
			if tp == Integer
				int = INTS[(len or 4)]
				raise('Unsupported integer size!') if int == nil
				return DbType.new(tp, int, int, null, nil)
			end
			
			(TYPES.has_key?(tp) ? DbType.new(tp, TYPES[tp], TYPES[tp], null, len) : nil)
		end
		
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
		
		def insert(to, values)
			args = []
			qry = "INSERT INTO #{obj_name(to.name)} (#{values.keys.collect(&method(:obj_name)).join(', ')}) values "
			qry += "(#{values.values.collect { |i| expression(i, args) }.join(', ')})"
			
			SqlQuery.new(qry + ';', *args)
		end
		
		def update(what, where, with)
			args = []
			qry = "UPDATE \"#{what.name}\" SET "
			qry += with.collect { |kvp| "#{obj_name(kvp[0])} = #{expression(kvp[1], args)}" }.join(', ')
			qry += " WHERE #{expression(where, args)}"
			
			SqlQuery.new(qry + ';', *args)
		end
		
		def delete(from, where)
			args = []
			qry = "DELETE FROM #{obj_name(from.name)} WHERE #{expression(where, args)}"
			
			SqlQuery.new(qry + ';', *args)
		end
		
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
		
		def db?(db)
			raise('Method not implemented!')
		end
		
		def create_db(db)
			raise('Method not implemented!')
		end
		
		def table?(db, tab)
			raise('Method not implemented!')
		end
		
		def create_table(db, tab)
			raise('Method not implemented!')
		end
		
		def create_foreign_key(db, ref)
			raise('Method not implemented!')
		end
		
		def create_index(db, idx)
			raise('Method not implemented!')
		end
		
		def obj_name(name)
			name
		end
		
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
		
		def initialize(itc, name, conf)
			super(itc, name, conf)
		end
		
		protected :db?, :table?, :create_db, :create_table, :create_foreign_key, :create_index, :obj_name
	end
end