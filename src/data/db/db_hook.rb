# Created by Matyáš Pokorný on 2019-05-27.

module ROM
	class DbHook
		include Component
		
		def name
			@name
		end
		
		def context
			@ctx
		end
		
		def initialize(itc, nm, ctx)
			@name = nm
			@ctx = ctx
		end
	end
end