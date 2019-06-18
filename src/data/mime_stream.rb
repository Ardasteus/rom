# Created by Matyáš Pokorný on 2019-06-18.

module ROM
	class MimeStream
		def type
			@type
		end
		
		def io
			@io
		end
		
		def initialize(type, io)
			@type = type
			@io = io
		end
	end
end