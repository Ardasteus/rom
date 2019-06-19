module ROM
	module HTTP
		class HTTPHeaderHandler
			include Component
			
			def initialize(itc, *hdr)
				@itc = itc
				@headers = hdr
			end
			
			def accepts?(hdr)
				@headers.include?(hdr)
			end
			
			def handle(hdr, value, ctx)
			
			end
		end
	end
end