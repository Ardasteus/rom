# Created by Matyáš Pokorný on 2019-05-18.

module ROM
	# Represents a DB key
	class DbKey
		# Gets the key name
		# @return [String] Key name
		def name
			@name
		end
		
		# Gets the table of key
		# @return [ROM::DbTable] Key table
		def table
			@tab
		end
		
		# Gets the columns of the key
		# @return [Array<ROM::DbColumn>] Key columns
		def columns
			@cols
		end
		
		# Instantiates the {ROM::DbKey} class
		# @param [ROM::DbTable] tab Table of key
		# @param [String] nm Name of key
		# @param [ROM::DbColumn] cols Key columns
		def initialize(tab, nm, *cols)
			@tab = tab
			@name = nm
			@cols = cols
		end
	end
end