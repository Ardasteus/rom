# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	# Contains information about differences in DB schema
	class DbStatus
		# Instantiates the {ROM::DbStatus} class
		def initialize
			@tabs = {}
		end
		
		# Adds information about table
		# @param [Symbol] tab Table to add status about
		# @param [Symbol] st Table status
		def table(tab, st)
			@tabs[tab] = st
		end
		
		# Checks whether table was newly created
		# @param [Symbol] tab Table to check the status of
		# @return [Boolean] True if table was newly created; false otherwise
		def new?(tab)
			@tabs[tab] == :new
		end
		
		# Gets the status of given table
		# @param [Symbol] tab Table to get the status of
		# @return [Symbol] Status of given table; nil if not found
		def status(tab)
			@tabs[tab]
		end
		
		# Checks whether the whole schema was newly created
		# @return [Boolean] True when all tables were newly created; false otherwise
		def regenerated?
			@tabs.all? { |i| i == :new }
		end
	end
end