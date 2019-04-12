module ROM
	module HTTP

		# Class to encapsule the HTTP content of the response
		class HTTPContent

			# HTTP headers
			# @return [Hash]
			def headers
				@headers
			end

			# Content's data stream
			# @return [IO]
			def stream
				@io
			end

			# Instantiates the {ROM::HTTPContent} class
			# @param [Stream] io Content
			# @param [Hash] headers Optional headers
			def initialize(io, **headers)
				@io = io
				@headers = headers
			end
		end
	end
end