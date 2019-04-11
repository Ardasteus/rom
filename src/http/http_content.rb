module ROM
	module HTTP
		class HTTPContent
			def headers
				@headers
			end

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