# Created by Matyáš Pokorný on 2019-05-18.

module ROM
	class DbResults
		def columns
			raise('Method not implemented!')
		end
		
		def next
			raise('Method not implemented!')
		end
		
		def [](key)
			raise('Method not implemented!')
		end
		
		def close
			raise('Method not implemented!')
		end
		
		def each
			rdr = RowReader.new(self)
			while self.next
				yield(rdr)
			end
		ensure
			close
		end
		
		class RowReader
			def [](key)
				@res[key]
			end
			
			def columns
				@res.columns
			end
			
			def initialize(res)
				@res = res
			end
		end
	end
end