module ROM
	module HTTP
		module Methods
			class OptionsMethod < HTTPMethod
				PREFIX = 'access_control_request'

				def initialize(itc)
					super(itc, 'options', false, false)
				end

				def resolve(http_request, input_serializer, output_serializer)
					hdr = {}
					http_request.headers.each_pair do |k, v|
						next unless k.to_s.start_with?(PREFIX)
						hdr[('access_control_allow' + k.to_s[PREFIX.length..k.to_s.length - 1]).to_sym] = v
					end
					hdr[:access_control_allow_origin] = http_request[:origin]

					HTTPResponse.new(StatusCode::NO_CONTENT, **hdr)
				end
			end
		end
	end
end