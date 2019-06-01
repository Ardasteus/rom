# Created by Matyáš Pokorný on 2019-05-12.

module ROM
	# A base class for DB drivers
	# @abstract
	class DbDriver
		include Component
		
		# Default naming conventions
		DEFAULT_CONVENTIONS = {
			:table => Proc.new { |tab| tab },
			:column => Proc.new { |tab, col| col },
			:pk_column => Proc.new { |tab, col| col },
			:fk_column => Proc.new { |src, tgt, dest, sfx| "#{tgt}#{dest}#{(sfx == '' ? '' : "_#{sfx}")}" },
			:pk_key => Proc.new { |tab, cols| "pk_#{tab}_#{cols.join('_')}" },
			:fk_key => Proc.new { |src, tgt, from, to| "fk_#{src}_#{from}" },
			:index => Proc.new { |tab, uq, cols| "ix_#{tab}_#{cols.join('_')}" }
		}
		
		# Gets the name of the DB driver
		# @return [String] Name of driver
		def name
			@name
		end
		
		# Gets the DB driver specific config model
		# @return [Class] DB driver config model
		def config_model
			@conf
		end
		
		# Resolves a type
		# @param [Class] tp Type to resolve
		# @param [Boolean] null True if type is nullable; false otherwise
		# @param [Integer, nil] len Length of the type
		# @return [ROM::DbType] Resolved DB type; nil if type couldn't be resolved
		def type(tp, null = false, len = nil)
			raise('Method not implemented!')
		end
		
		# Gets the by-convention name of an object
		# @param [Symbol] nm Name of convention to apply
		# @param [Object] args Arguments of convention transformation
		# @return [String] Converted name
		def convention(nm, *args)
			DEFAULT_CONVENTIONS[nm]&.call(*args)
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
			raise('Method not implemented!')
		end
		
		# Generates a single row selection query
		# @param [ROM::DbTable] from Selection source table
		# @param [ROM::Queries::QueryExpression, nil] where Filtering expression
		# @return [ROM::Entity, nil] Found entity; nil otherwise
		def find(from, where = nil)
			select(from, where, [], nil, 1)
		end
		
		# Generates a single row insertion query
		# @param [ROM::DbTable] to Target table
		# @param [Hash{String=>ROM::Queries::QueryExpression}] values Hash of column names and their value expressions
		# @return [ROM::SqlQuery] Generated query
		def insert(to, values)
			raise('Method not implemented!')
		end
		
		# Generates an update query
		# @param [ROM::DbTable] what Table to update
		# @param [ROM::Queries::QueryExpression] where Filtering expression
		# @param [Hash{String=>ROM::Queries::QueryExpression}] with Hash of column names and their value expressions
		# @return [ROM::SqlQuery] Generated query
		def update(what, where, with)
			raise('Method not implemented!')
		end
		
		# Generates a delete query
		# @param [ROM::DbTable] from Table to delete rows from
		# @param [ROM::Queries::QueryExpression] where Filtering expression
		# @return [ROM::SqlQuery] Generated query
		def delete(from, where)
			raise('Method not implemented!')
		end
		
		# Instantiates the {ROM::DbDriver} class
		# @param [ROM::Interconnect] itc Registering interconnect of component
		# @param [String] nm Name of driver
		# @param [Class] conf Configuration model
		def initialize(itc, nm, conf)
			@name = nm
			@itc = itc
			@conf = conf
		end
		
		# Opens a DB connection
		# @param [Object] conf Connection configuration
		# @return [ROM::DbConnection] Opened connection handle
		def connect(conf)
			raise('Method not implemented!')
		end
		
		# Creates the DB schema
		# @param [ROM::DbConnection] db Connection to DB
		# @param [ROM::DbSchema] schema Schema to generate
		# @return [ROM::DbStatus] Schema generation status
		def create(db, schema)
			raise('Method not implemented!')
		end
	end
end