# Created by Matyáš Pokorný on 2019-05-18.

module ROM
	# Represents a DB query result set
	# @abstract
	class DbResults
		# Gets the names of returned columns
		# @return [Array<string>] Returned columns
		def columns
			raise('Method not implemented!')
		end
		
		# Fetches next record
		# @return [Boolean] True if row was fetched; false otherwise
		def next
			raise('Method not implemented!')
		end
		
		# Gets the value of column on current row
		# @param [String] key Column to fetch
		# @return [Object, nil] Value in the given column on current row
		def [](key)
			raise('Method not implemented!')
		end
		
		# Closes the reader
		def close
			raise('Method not implemented!')
		end
		
		# Iterates through all row in the reader
		# @yield [row] Iterator
		# @yieldparam [ROM::DbResults::RowReader] row Row reader of record
		def each
			rdr = RowReader.new(self)
			while self.next
				yield(rdr)
			end
		ensure
			close
		end
		
		# Reads one row of result set
		class RowReader
			# Gets the value of column on current row
			# @param [String] key Column to fetch
			# @return [Object, nil] Value in the given column on current row
			def [](key)
				@res[key]
			end
			
			# Gets the names of returned columns
			# @return [Array<string>] Returned columns
			def columns
				@res.columns
			end
			
			# Instantiates the {ROM::DbResults::RowReader} class
			# @param [ROM::DbResults] res Result set to read from
			def initialize(res)
				@res = res
			end
		end
	end
end