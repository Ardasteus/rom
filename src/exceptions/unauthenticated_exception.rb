# Created by Matyáš Pokorný on 2019-06-04.

module ROM
	class UnauthenticatedException < ApiException
		def initialize
			super('User failed to authenticate!')
		end
	end
end