module ROM
	class HTTPContent

		def header
			@headers
		end

		def stream
			@io
		end
		
		def intiliiaze(io, headers)
			@io = io
			@headers = headers
		end
	end
end