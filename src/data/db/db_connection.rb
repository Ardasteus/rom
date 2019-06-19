# Created by Matyáš Pokorný on 2019-05-18.

module ROM
	# Base class of a DB connection handler
	# @abstract
	class DbConnection
		# Gets the driver that manages the connection
		# @return [ROM::DbDriver] Driver that manages the connection
		def driver
			@dvr
		end
		
		# Instantiates the {ROM::DbConnection} class
		# @param [ROM::DbDriver] dvr Driver that manages the connection
		def initialize(dvr)
			@dvr = dvr
		end
		
		# Gets the name of the connection
		# @return [String] Name of the connection
		def name
			raise('Method not implemented!')
		end
		
		# Executes a DB query
		# @param [ROM::SqlQuery] q Query to execute
		# @return [ROM::DbResults] DB query results reader
		def query(q)
			raise('Method not implemented!')
		end
		
		# Executes a DB query, discarding the results
		# @param [ROM::SqlQuery] q Query to execute
		def execute(q)
			query(q).close
		end
		
		# Executes a DB query which results in a scalar value
		# @param [ROM::SqlQuery] q Query to execute
		# @return [Object, nil] Resulting scalar value of the given query
		def scalar(q)
			query(q).each do |row|
				return row[row.columns.first]
			end
			
			raise("Query didn't yield any results!")
		end
		
		# Ensures that the target DB is selected
		def select_db
			raise('Method not implemented!')
		end
		
		# Gets the ID of the last inserted row
		# @return [Object, nil] IO of the last inserted row
		def last_id
			raise('Method not implemented!')
		end
		
		# Closes the DB connection
		def close
			raise('Method not implemented!')
		end
	end
end