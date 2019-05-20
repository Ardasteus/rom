# Created by Matyáš Pokorný on 2019-05-13.

module ROM
	module Sqlite
		class SqliteDriver < DbDriver
			TYPES = {
				Integer => DbType.new(Integer, 'INT'),
				String => DbType.new(String, 'NVARCHAR(512)'),
				Types::Boolean => DbType.new(Types::Boolean, 'BIT')
			}
			
			QUERIES = {
				:table => Proc.new { |tab|
					qry = "CREATE TABLE \"#{tab.name}\" ("
					qry += tab.columns.collect { |col| "\"#{col.name}\" #{col.type.type}#{col.type.length == nil ? '' : "(#{col.type.length})"}" }.join(', ')
					unless tab.primary_key == nil
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
				qry = "SELECT "
				if vals == nil
					qry += "* "
				else
					vals.each_pair { |k, v| qry += "#{expression(v, args)} as \"#{k.to_s}\"" }
				end

				qry += "FROM \"#{from.name}\""

				unless where == nil
					raise('WHERE requires the expression to result in boolean!') unless where.type < Types::Boolean[]
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
					when ColumnValue
						expr.column.name.to_s
					when ConstantValue
						args << case expr.value
							when true
								1
							when false
								0
							else
								expr.value
						end

						'?'
					when BinaryOperator
						"(#{expression(expr.left, args)} #{expr.operator.name} #{expression(expr.right, args)})"
					when FunctionExpression
						
				end
			end
			
			def type(tp)
				TYPES[tp]
			end
			
			def initialize(itc)
				super(itc, 'Sqlite', SqliteConfig)
			end
			
			def connect(conf)
				SqliteConnection.new(SQLite3::Database.new(conf.file, { :type_translation => true }))
			end
			
			class SqliteConnection < DbConnection
				def name
					'sqlite'
				end
				
				def query(q)
					Results.new(@db.query(q.query, q.arguments))
				end
				
				def initialize(db)
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