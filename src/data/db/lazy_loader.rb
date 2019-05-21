# Created by Matyáš Pokorný on 2019-05-19.

module ROM
	class LazyLoader
		def initialize(db, tab, map)
			@db = db
			@tab = tab
			@map = map
		end
		
		def fetch(keys)
			qry = @db.driver.find(@tab, keys.reduce(nil) { |n, kvp| eq = Queries::ColumnValue.new(kvp[0].reference.target) == kvp[1]; (n == nil ? eq : n.and(eq)) })
			@db.query(qry).each do |row|
				return @map.map(row)
			end
			
			raise('Reference not satisfied!')
		end
	end
end