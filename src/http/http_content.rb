module ROM
	class HTTPContent

		def headers
			@headers
		end

		def stream
			@io
		end
		
		def initialize(io, **headers)
			@io = io
			@headers = headers
		end
	end
end