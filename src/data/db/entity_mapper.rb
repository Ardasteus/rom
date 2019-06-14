# Created by Matyáš Pokorný on 2019-05-19.

module ROM
	# Maps DB rows to entities
	class EntityMapper
		# Instantiates the {ROM::EntityMapper} class
		# @param [ROM::DbTable] tab Mapped table
		# @param [Hash{Symbol=>ROM::LazyLoader}] lazy By-reference hash of lazy loaders for referencing columns
		def initialize(tab, lazy)
			@tab = tab
			@lazy = lazy
		end
		
		# Maps all rows of result set
		# @param [ROM::DbResults] res Result set to map
		# @return [Array<ROM::Entity>] Mapped entities
		def map_all(res)
			ret = []
			res.each { |row| ret << map(row) }
			
			ret
		end
		
		# Maps a single DB row to an entity
		# @param [ROM::DbResults::RowReader] row Row to map into an entity
		# @return [ROM::Entity] Mapped entity
		def map(row)
			vals = {}
			@tab.columns.each do |col|
				val = row[col.name]
				keys = { col => val }
				vals[col.mapping.name.to_sym] = ((val != nil and is_lazy?(col.mapping.type)) ? LazyPromise.new(keys, @tab) { @lazy[col.name.to_sym].fetch(keys) } : val)
			end
			
			Entity.new(@tab, vals)
		end
		
		def is_lazy?(klass)
			case klass
				when Types::Just
					klass.type <= Model
				when Types::Union
					klass.types.any?(&method(:is_lazy?))
				else
					false
			end
		end
	end
end