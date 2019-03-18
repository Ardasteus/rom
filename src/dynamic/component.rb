# Created by Matyáš Pokorný on 2019-03-17.

module ROM
	module Component
		def self.included(klass)
			klass.extend ClassMethods
		end
		
		module ClassMethods
			def register(itc)
				[self.new(itc)]
			end
		end
	end
end