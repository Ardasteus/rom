# Created by Matyáš Pokorný on 2019-03-23.

module ROM
	class Config
		include Component
		
		def name
			@name
		end
		
		def model
			@mod
		end
		
		def initialize(name, mod)
			@name = name
			@mod = mod
		end
		
		def load(cfg)
			raise('Method not implemented!')
		end
	end
end