# Created by Matyáš Pokorný on 2019-06-13.

module ROM
	class NotImplementedException < ApiException
		def initialize
			super('Functionality is not implemented!')
		end
	end
end