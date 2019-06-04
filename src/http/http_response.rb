module ROM
	module HTTP

		# Class that encapsulates a HTTP response
		class HTTPResponse
			# End of line constant
			EOL = "\r\n"
			
			# Status code of the HTTP response
			# @return [StatusCode]
			def code
				@code
			end
			
			# Headers of the HTTP response
			# @return [Hash]
			def headers
				@headers
			end
			
			def [](header)
			   @headers[header]
			end

			# Content of the HTTP response
			# @return [HTTPContent]
			def content
				@content
			end
			
			# Instantiates the {ROM::HTTPResponse} class
			# @param [int] code Code of the response, for example 200 OK
			# @param [ROM::HTTPContent] content Content of the response
			# @param [hash] headers Custom headers that override the content ones
			def initialize(code, content = nil, **headers)
				@code    = code
				@headers = create_headers(content, headers)
				@content = content
			end
			
			# Merges the content and custom header together, custom ones have priority
			# @param [ROM::HTTPContent] content Content of the response
			# @param [hash] headers Custom headers
			def create_headers(content, headers)
				hdrs = {}
				
				content.headers.each_pair { |key, value| hdrs[key] = value } unless content == nil
				
				headers.each_pair do |key, value|
					hdrs[key] = value
				end
				
				hdrs[:content_length] = 0 unless hdrs.has_key?(:content_length)
				hdrs[:server] = "Ruby on Mails v#{ROM::VERSION}" unless hdrs.has_key?(:server)
				return hdrs
			end
			
			# Transforms the header back from symbol to a string
			# @param [symbol] header Header to transform
			def header_key(header)
				header.to_s.split('_').collect(&:capitalize).join('-')
			end
			
			# Creates a string from the whole response
			# @return [String]
			def stringify
				response = "HTTP/1.1 #{@code}#{EOL}"
				
				@headers.each_pair do |key, value|
          if value.is_a?(Array)
						value.each do |val|
							response += header_key(key) + ": " + val.to_s + EOL
						end
          else
						response += header_key(key) + ": " + value.to_s + EOL
          end
				end
				response += EOL
				response += @content.stream.read unless @content&.stream == nil
				
				return response
			end
		end
	end
end