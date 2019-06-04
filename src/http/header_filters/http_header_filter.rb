module ROM
	module HTTP
		class HTTPHeaderFilter
			include Component
			
			def required?
				@required
			end
			
			def initialize(itc, req, *hdr)
				@itc = itc
				@required = req
				@headers = hdr
			end
			
			def accepts?(hdr)
				@headers.include?(hdr)
			end
			
			def filter(hdr, value)
			
			end
		end
	end
end