module ROM
	module HTTP
		
		# Class that handles the routing of HTTP calls into API calls
		class HTTPAPIResolver
			include Component
			
			EXCEPTION_CODES = {
				PlanningException => StatusCode::NOT_FOUND,
				ArgumentException => StatusCode::BAD_REQUEST,
				SignatureException => StatusCode::BAD_REQUEST,
				UnauthenticatedException => StatusCode::UNAUTHORIZED,
				CharsetNotFoundException => StatusCode::BAD_REQUEST,
				UnauthorizedException => StatusCode::FORBIDDEN,
				NotFoundException => StatusCode::NOT_FOUND,
				InvalidOperationException => StatusCode::CONFLICT,
				NotImplementedException => StatusCode::NOT_IMPLEMENTED,
				UnknownMediaTypeException => StatusCode::UNSUPPORTED_MEDIA_TYPE
			}
			DEFAULT_ENCODING = Encoding::UTF_8
			
			# Instantiates the {ROM::HTTP::HTTPAPIResolver} class
			# @param [ROM::Interconnect] itc Interconnect
			def initialize(itc)
				@itc = itc
				@gateway = itc.fetch(ApiGateway)
				@http_methods = itc.view(HTTPMethod)
				@header_filters = itc.view(HTTPHeaderFilter)
				@log = itc.pin(LogServer)
				@json = itc.pin(DataSerializers::JsonSerializerProvider)
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
					method = @http_methods.find { |mtd| mtd.is_method?(request.method) }
					return HTTPResponse.new(StatusCode::METHOD_NOT_ALLOWED) if method == nil
					
					resp = method.resolve(request)
					resp[:access_control_allow_origin] = request[:origin] if (request[:origin] != nil and resp[:access_control_allow_origin] == nil)
					
					resp
				rescue ApiException => ex
					status = EXCEPTION_CODES[ex.class]
					if status != nil
						HTTPResponse.new(status)
					else
						@log.item&.error('Unknown API exception raised during HTTP request!', ex)
						
						HTTPResponse.new(StatusCode::INTERNAL_SEVER_ERROR)
					end
				rescue Exception => ex
					@log.item&.error('Unknown exception raised during HTTP request!', ex)
					
					HTTPResponse.new(StatusCode::INTERNAL_SEVER_ERROR)
				end
			end
		end
	end
end