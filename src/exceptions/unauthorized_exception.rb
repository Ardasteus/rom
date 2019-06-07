# Created by Matyáš Pokorný on 2019-06-08.

module ROM
	class UnauthorizedException < ApiException
		def initialize
			super('User is not authorized!')
		end
	end
end