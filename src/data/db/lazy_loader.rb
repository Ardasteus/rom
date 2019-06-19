# Created by Matyáš Pokorný on 2019-05-19.

module ROM
	# Loads entities lazily
	class LazyLoader
		# Instantiates the {ROM::LazyLoader} class
		# @param [ROM::DbConnection] db DB connection to load entities from
		# @param [ROM::DbTable] tab Table to read entities from
		# @param [ROM::EntityMapper] map Mapper used to map the entities
		def initialize(db, tab, map)
			@db = db
			@tab = tab
			@map = map
		end
		
		# Fetches an entity based on its referred key
		# @param [Hash{ROM::DbColumn=>[Object, nil]}] key Key of entity to fetch
		# @return [ROM::Entity] Fetched entity
		def fetch(keys)
			qry = @db.driver.find(@tab, keys.reduce(nil) { |n, kvp| eq = Queries::ColumnValue.new(kvp[0].reference.target) == kvp[1]; (n == nil ? eq : n.and(eq)) })
			@db.query(qry).each do |row|
				return @map.map(row)
			end
			
			raise('Reference not satisfied!')
		end
	end
end