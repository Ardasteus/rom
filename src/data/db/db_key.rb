# Created by Matyáš Pokorný on 2019-05-18.

module ROM
	class DbKey
		def name
			@name
		end
		
		def table
			@tab
		end
		
		def columns
			@cols
		end
		
		def initialize(tab, nm, *cols)
			@tab = tab
			@name = nm
			@cols = cols
		end
	end
end