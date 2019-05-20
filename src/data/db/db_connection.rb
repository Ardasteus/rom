# Created by Matyáš Pokorný on 2019-05-18.

module ROM
	class DbConnection
		def driver
			@dvr
		end
		
		def initialize(dvr)
			@dvr = dvr
		end
		
		def name
			raise('Method not implemented!')
		end
		
		def query(q)
			raise('Method not implemented!')
		end
		
		def execute(q)
			query(q).close
		end
		
		def scalar(q)
			query(q).each do |row|
				return row[row.columns.first]
			end
			
			raise("Query didn't yield any results!")
		end
		
		def last_id
			raise('Method not implemented!')
		end
		
		def close
			raise('Method not implemented!')
		end
	end
end