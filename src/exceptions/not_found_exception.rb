# Created by Matyáš Pokorný on 2019-06-12.

module ROM
	class NotFoundException < ApiException
		def initialize(res)
			super("Resource not found!: #{res}")
		end
	end
end