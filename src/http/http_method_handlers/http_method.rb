module ROM
	module HTTP
		# Base class for all HTTP method handlers
		class HTTPMethod
			include Component
			modifiers :abstract
			
			DEFAULT_ENCODING = Encoding::UTF_8
			
			# Instantiates the {ROM::HTTP::Methods::HTTPMethod} class
			# @param [ROM::Interconnect] itc Interconnect
			def initialize(itc, name)
				@itc = itc
				@name = name.upcase
				@gateway = itc.pin(ApiGateway)
				@handlers = itc.view(HTTPHeaderHandler)
				@json = itc.pin(DataSerializers::JsonSerializerProvider)
				@serializers = itc.view(SerializerProvider)
			end
			
			# Resolves the given http request and formats the content with the given input/output serializers
			# @param [ROM::HTTP::HTTPRequest] http_request HTTP request to resolve
			def resolve(http_request)
			end
			
			def get_plan(*paths)
				f = nil
				paths.each do |path|
					begin
						plan = @gateway.plan(*path)
						raise('API call plan returns a resource!') if plan.signature.return_type <= Resource
						return plan
					rescue Exception => ex
						f = ex if f == nil
					end
				end
				
				raise(PlanningException.new(paths.first))
			end
			
			# Checks if the given method is corresponding to the method of [HTTPMethod] class
			# @return [Boolean]
			def is_method?(mtd)
				@name == mtd.upcase
			end
			
			# Creates an array of symbols from the request path
			# @param [String] input Path to format
			def format_path(input)
				path = input
				path[0] = '' if path[0] == '/'
				path = path.split('/')
				
				path.map(&:to_sym)
			end
			
			# Runs the given api plan, invoking it with arguments depending on the type of the request's content
			# @param [ROM::ApiPlan] plan Plan to run
			# @param [ROM:HTTP:HTTPRequest] request HTTP Request
			def run_plan(plan, request)
				ctx = ApiContext.new(@itc)
				request.headers.each_pair do |k, v|
					@handlers.select { |i| i.accepts?(k) }.each do |h|
						h.handle(k, v, ctx)
					end
				end
				
				if plan.attribute?(AuthorizeAttribute)
					raise(UnauthenticatedException.new) if ctx.identity == nil
					plan.attribute(AuthorizeAttribute).each do |att|
						att.judgements.each do |jdg|
							raise(UnauthorizedException.new) unless jdg.judge(ctx.identity)
						end
					end
				end
				args = []
				body = if plan.signature[0] != nil
					arg = plan.signature[0]
					if arg[:type] <= Model or arg[:type] <= MimeStream
						arg
					else
						nil
					end
				else
					nil
				end
				if body != nil
					type = body[:type]
					if type <= MimeStream
						args << MimeStream.new(ContentType.from_header(request[:content_type]).type, BoundedIO.new(request.stream, request[:content_length].to_i))
					elsif type <= Model
						length = request[:content_length].to_i
						args << if length == 0
							raise(ArgumentException.new(body[:name], 'Body expected!')) unless type <= NilClass
							args << nil
						else
							buffer = StringIO.new
							bytes = IO.copy_stream(request.stream, buffer, request[:content_length].to_i)
							raise('Failed to read body!') if bytes != length
							buffer.pos = 0
							type.type.from_object(input_serializer(request).to_object(buffer))
						end
					elsif body[:required]
						raise("Unknown API action input argument type '#{type}'!")
					end
				end
				plan.signature.each do |arg|
					next if arg == body
					
					val = request.query[arg[:name].to_s]
					raise(ArgumentException.new(arg[:name], 'Argument required!')) if arg[:required] and val == nil
					args << (val == nil ? arg[:default] : arg_val(arg[:name], arg[:type], val))
				end
				unk = request.query.keys.find { |k| plan.signature[k.to_sym] == nil }
				raise(ArgumentException.new(unk, 'Unknown action argument!')) if unk != nil
				
				plan.run(ctx, *args)
			end
			
			def get_response(status, plan, req, res)
				return HTTPResponse.new(StatusCode::NO_CONTENT) if plan.signature.return_type <= Types::Void
				http_content = if plan.signature.return_type <= MimeStream
					StreamContent.new(res)
				else
					ObjectContent.new(res, output_serializer(req))
				end
				
				HTTPResponse.new(status, http_content)
			end
			
			def input_serializer(req)
				content = (req[:content_length] != nil and req[:content_length].to_i > 0)
				content_type = (req[:content_type] == nil ? nil : ContentType.from_header(req[:content_type]))
				return nil if content_type == nil
				
				encoding = if content_type.charset != nil
					begin
						Encoding.find(content_type.charset)
					rescue ArgumentError
						raise(CharsetNotFoundException.new(content_type.charset))
					end
				else
					DEFAULT_ENCODING
				end
				
				ret = @serializers.find { |i| i.accepts?(content_type.type) }&.get_serializer(content_type, encoding)
				raise(UnknownMediaTypeException.new(content_type.type)) if ret == nil
				raise(ArgumentException.new('Content-Type', 'Content type required!')) if content and ret == nil
				
				ret
			end
			
			def output_serializer(req)
				@json.get_serializer(nil, DEFAULT_ENCODING)
			end
			
			def arg_val(name, type, val)
				if type <= String
					val
				elsif type <= Integer
					return val.to_i if val =~ /(\+|\-)?\d+/
					raise(ArgumentException.new(name, "Cannot cast '#{val}' as integer!"))
				elsif type <= Types::Boolean
					case val.downcase.strip
						when 'true', '1'
							true
						when 'false', '0'
							false
						else
							raise(ArgumentException.new(name, "Cannot cast '#{val}' as boolean!"))
					end
				else
					raise(ArgumentException.new(name, "Argument is of unsupported type!: #{type.name}"))
				end
			end
		end
	end
end