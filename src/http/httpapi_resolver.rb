module ROM
	module HTTP
		
		# Class that handles the routing of HTTP calls into API calls
		class HTTPAPIResolver
			include Component
			
			EXCEPTION_CODES = {
				PlanningException => StatusCode::NOT_FOUND,
				ArgumentException => StatusCode::BAD_REQUEST,
				SignatureException => StatusCode::BAD_REQUEST,
				UnauthenticatedException => StatusCode::UNAUTHORIZED
			}
			
			# Instantiates the {ROM::HTTP::HTTPAPIResolver} class
			# @param [ROM::Interconnect] itc Interconnect
			def initialize(itc)
				@itc = itc
				@gateway = itc.fetch(ApiGateway)
				@serializers = itc.view(DataSerializers::Serializer)
				@http_methods = itc.view(HTTPMethod)
				@header_filters = itc.view(HTTPHeaderFilter)
				@log = itc.pin(LogServer)
				@json = itc.pin(DataSerializers::JSONSerializer)
			end
			
			# Resolves the given http request, fetching the correct {ROM::HTTP::Methods::HTTPMethod} and input/output {ROM::DataSerializers::Serializer} based on the http request headers
			# @param [ROM::HTTP::HTTPRequest] http_request HTTP request to resolve
			# @return [ROM::HTTP::HTTPResponse]
			def resolve(http_request)
				request = http_request
				
				found = []
				request.headers.each_pair do |k, v|
					@header_filters.select { |i| i.accepts?(k) }.each do |filter|
						next if filter == nil
						found << filter unless found.include?(filter)
						n = filter.filter(k, v)
						return n unless n == nil
					end
				end
				
				filter = @header_filters.select { |i| i.required? }.find { |i| not found.include?(i) }
				return HTTPResponse.new(StatusCode::BAD_REQUEST) unless filter == nil
				
				begin
					method = @http_methods.find { |mtd| mtd.is_name(request.method) }
					return HTTPResponse.new(StatusCode::METHOD_NOT_ALLOWED) if method == nil
					
					input_serializer = @serializers.find { |srl| srl.is_content_type(request[:content_type]) }
					return HTTPResponse.new(StatusCode::UNSUPPORTED_MEDIA_TYPE) if input_serializer == nil and request[:content_type] != nil
					return HTTPResponse.new(StatusCode::BAD_REQUEST) if input_serializer == nil and method.input?
					
					output_serializer = @serializers.find { |srl| srl.is_content_type(request[:accepts]) }
					return HTTPResponse.new(StatusCode::NOT_ACCEPTABLE) if output_serializer == nil and request[:accepts] != nil
					
					output_serializer = (output_serializer or @json)
					
					method.resolve(request, input_serializer, output_serializer)
				rescue ApiException => ex
					HTTPResponse.new(EXCEPTION_CODES[ex.class])
				rescue Exception => ex
					@log.item&.error('Unknown exception raised during HTTP request!', ex)
					
					HTTPResponse.new(StatusCode::INTERNAL_SEVER_ERROR)
				end
			end
		end
	end
end