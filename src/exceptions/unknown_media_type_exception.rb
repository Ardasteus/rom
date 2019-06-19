# Created by Matyáš Pokorný on 2019-06-18.

module ROM
	class UnknownMediaTypeException < ApiException
		def initialize(type)
			super("Media type '#{type}' isn't known!")
		end
	end
end