module ROM
	module HTTP
		module Methods
			class OptionsMethod < HTTPMethod
				PREFIX = 'access_control_request_'

				def initialize(itc)
					super(itc, 'options')
				end

				def resolve(http_request)
					hdr = {}
					http_request.headers.each_pair do |k, v|
						next unless k.to_s.start_with?(PREFIX)
						opt = k.to_s[PREFIX.length..k.to_s.length - 1]
						opt = 'methods' if opt == 'method'
						hdr[('access_control_allow_' + opt).to_sym] = v
					end
					hdr[:access_control_allow_origin] = http_request[:origin]

					HTTPResponse.new(StatusCode::NO_CONTENT, **hdr)
				end
			end
		end
	end
end