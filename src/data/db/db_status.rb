# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	class DbStatus
		def initialize
			@tabs = {}
		end
		
		def table(tab, st)
			@tabs[tab] = st
		end
		
		def new?(tab)
			@tabs[tab] == :new
		end
		
		def status(tab)
			@tabs[tab]
		end
		
		def regenerated?
			@tabs.all? { |i| i == :new }
		end
	end
end