# Created by Matyáš Pokorný on 2019-03-24.

module ROM
	class Attribute
		def self.[](*args)
			return self.new(*args)
		end
	end
end