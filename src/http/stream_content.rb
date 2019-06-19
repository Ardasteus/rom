# Created by Matyáš Pokorný on 2019-06-18.

module ROM
	module HTTP
		class StreamContent < HTTPContent
			def initialize(str, **headers)
				@str = str
				io = str.io
				super(io, :content_type => str.type, :content_length => io.length, **headers)
			end
		end
	end
end