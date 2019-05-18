# Created by Matyáš Pokorný on 2019-05-18.

module ROM
	class DbConnection
		def name
			raise('Method not implemented!')
		end
		
		def query(q)
			raise('Method not implemented!')
		end
		
		def execute(q)
			query(q).close
		end
		
		def close
			raise('Method not implemented!')
		end
	end
end