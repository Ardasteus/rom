# Created by Matyáš Pokorný on 2019-05-13.

module ROM
	module Sqlite
		class SqliteDriver < DbDriver
			TYPES = {
				Integer => DbType.new(Integer, 'INTEGER'),
				String => DbType.new(String, 'NVARCHAR(512)'),
				Types::Boolean => DbType.new(Types::Boolean, 'BIT')
			}
			
			QUERIES = {
				:table => Proc.new { |tab|
					qry = "CREATE TABLE \"#{tab.name}\" ("
					pk_exp = (tab.primary_key != nil and tab.primary_key.columns.size == 1 ? tab.primary_key.columns.first : nil)
					qry += tab.columns.collect { |col| "\"#{col.name}\" #{col.type.type}#{col.type.length == nil ? '' : "(#{col.type.length})"}#{(pk_exp == col ? ' PRIMARY KEY' : '')}" }.join(', ')
					unless tab.primary_key == nil or pk_exp != nil
						qry += ", PRIMARY KEY (#{tab.primary_key.columns.collect { |i| "\"#{i.name}\"" }.join(', ')})"
					end
					qry += ');'
					SqlQuery.new(qry)
				},
				:table? => Proc.new { |tab|
					SqlQuery.new("SELECT count(*) FROM sqlite_master WHERE type='table' AND name=?;", tab.name)
				},
				:index => Proc.new { |name, tab, uq, cols|
					SqlQuery.new("CREATE#{uq ? ' UNIQUE' : ''} INDEX \"#{name}\" ON \"#{tab}\"(#{cols.collect { |i| "\"#{i.name}\"" }.join(', ')})")
				}
			}
			
			def create(db, schema)
				schema.tables.each do |tab|
					db.execute(query(:table, tab))
					tab.indices.each do |idx|
						db.execute(query(:index, idx.name, idx.table.name, idx.unique?, idx.columns))
					end
				end
				schema.references.each do |ref|
					# References are substituted by indices
					db.execute(query(:index, ref.name, ref.from.table.name, false, [ref.from]))
				end
			end
			
			def query(nm, *args)
				QUERIES[nm]&.call(*args)
			end
			
			def select(from, where = nil, ord = [], vals = nil, limit = nil, offset = nil)
				args = []
				qry = "SELECT " +
					if vals == nil
						'*'
					else
						vals.collect { |kvp| "#{expression(kvp[1], args)} as \"#{kvp[0].to_s}\"" }.join(', ')
					end
				
				qry += " FROM \"#{from.name}\""
				
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
				
				SqlQuery.new(qry, *args)
			end
			
			def expression(expr, args)
				case expr
					when Queries::ColumnValue
						"\"#{expr.column.table.name}\".\"#{expr.column.name}\""
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
			
			def type(tp)
				TYPES[tp]
			end
			
			def initialize(itc)
				super(itc, 'Sqlite', SqliteConfig)
			end
			
			def connect(conf)
				SqliteConnection.new(self, SQLite3::Database.new(conf.file, { :type_translation => true }))
			end
			
			class SqliteConnection < DbConnection
				def name
					'sqlite'
				end
				
				def query(q)
					puts "SQLITE: #{q.query}"
					Results.new(@db.query(q.query, q.arguments))
				end
				
				def initialize(dvr, db)
					super(dvr)
					@db = db
				end
				
				def close
					@db.close
				end
				
				class Results < DbResults
					def columns
						@cols
					end
					
					def initialize(res)
						@cols = res.columns
						@res = res
						@row = nil
					end
					
					def next
						@row = @res.next
					end
					
					def [](key)
						key = key.to_s
						
						@row[@cols.index { |i| i == key }]
					end
					
					def close
						@res.close
					end
				end
			end
			
			class SqliteConfig < Model
				property! :file, String
			end
		end
	end
end