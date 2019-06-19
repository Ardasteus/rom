module ROM
	# Represents an SQL query
	class SqlQuery
		# Gets the SQL query text
		# @return [String] SQL query
		def query
			@query
		end

		# Gets the query arguments
		# @return [Array<[Object, nil]>] Query arguments
		def arguments
			@args
		end
		
		# Instantiates the {ROM::SqlQuery} class
		# @param [String] qry SQL query text
		# @param [Object, nil] args Query arguments
		def initialize(qry, *args)
			@query = qry
			@args = args
		end
	end
end