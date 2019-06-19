module ROM
	module HTTP
		module Methods
			
			# Class that handles all DELETE HTTP requests
			class DeleteMethod < HTTPMethod
				
				# Instantiates the {ROM::HTTP::Methods::HTTPMethod} class
				# @param [ROM::Interconnect] itc Interconnect
				def initialize(itc)
					super(itc, 'delete')
				end
				
				# Resolves the given http request and formats the content with the given input/output serializers
				# @param [ROM::HTTP::HTTPRequest] http_request HTTP request to resolve
				def resolve(http_request)
					request = http_request
					path = format_path(request.path)
					
					plan = get_plan(path + [:delete])
					run_plan(plan, request)
					
					HTTPResponse.new(StatusCode::NO_CONTENT)
				end
			end
		end
	end
end
