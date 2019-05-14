module ROM
	class SqlQuery
		def query
			@query
		end

		def arguments
			@args
		end

		def initialize(qry, *args)
			@query = qry
			@args = args
		end
	end
end