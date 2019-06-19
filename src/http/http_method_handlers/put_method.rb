module ROM
	module HTTP
		module Methods
			
			# Class that handles all PUT HTTP requests
			class PutMethod < HTTPMethod
				
				# Instantiates the {ROM::HTTP::Methods::PutMethod} class
				# @param [ROM::Interconnect] itc Interconnect
				def initialize(itc)
					super(itc, 'put')
				end
				
				# Resolves the given http request and formats the content with the given input/output serializers
				# @param [ROM::HTTP::HTTPRequest] http_request HTTP request to resolve
				def resolve(http_request)
					request = http_request
					path = format_path(request.path)
					
					plan = get_plan(path + [:update])
					value = run_plan(plan, request)
					
					get_response(StatusCode::OK, plan, request, value)
					# return HTTPResponse.new(StatusCode::NO_CONTENT) if plan.signature.return_type <= Types::Void
					# http_content = ObjectContent.new(value, output_serializer(request))
					#
					# HTTPResponse.new(StatusCode::OK, http_content)
				end
			end
		end
	end
end