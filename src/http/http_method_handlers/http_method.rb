module ROM
	module HTTP
		# Base class for all HTTP method handlers
		class HTTPMethod
			include Component
			
			def input?
				@input
			end
			
			def output?
				@output
			end
			
			# Instantiates the {ROM::HTTP::Methods::HTTPMethod} class
			# @param [ROM::Interconnect] itc Interconnect
			def initialize(itc, name, i, o)
				@itc = itc
				@name = name.upcase
				@input = i
				@output = o
				@gateway = itc.fetch(ApiGateway)
				@handlers = itc.view(HTTPHeaderHandler)
			end
			
			# Resolves the given http request and formats the content with the given input/output serializers
			# @param [ROM::HTTP::HTTPRequest] http_request HTTP request to resolve
			# @param [ROM::DataSerializers::Serializer] input_serializer Input serializer, based on the Content-Type header
			# @param [ROM::DataSerializers::Serializer] output_serializer Output serializer, based on the Accepts header, defaults to {ROM::DataSerializers::JSONSerializer}
			def resolve(http_request, input_serializer, output_serializer)
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
			# @param [ROM::DataSerializers::Serializer] serializer Input serializer to read the request's content
			def run_plan(plan, request, serializer)
				ctx = ApiContext.new(@itc)
				request.headers.each_pair do |k, v|
					@handlers.select { |i| i.accepts?(k) }.each do |h|
						h.handle(k, v, ctx)
					end
				end
				
				args = []
				body = plan.signature[0]
				if body != nil
					type = body[:type]
					if type <= IO
						args << request.stream
					elsif type <= Model
						data = request.stream.read(request[:content_length].to_i)
						
						args << if data == nil
							raise(ArgumentException.new(body[:name], 'Body expected!')) unless type <= NilClass
							args << nil
						else
							type.type.from_object(serializer.to_object(data))
						end
					elsif body[:required]
						raise("Unknown API action input argument type '#{type}'!")
					end
				end
				plan.signature.each do |arg|
					next if arg == body
					
					val = request.query[arg[:name].to_s]
					raise(ArgumentException.new(arg[:name], 'Argument required!')) if arg[:required] and val == nil
					raise(ArgumentException.new(arg[:name], "Argument doesn't accept String!")) unless arg[:type] <= String
					args << (val == nil ? arg[:default] : val)
				end
				unk = request.query.keys.find { |k| plan.signature[k.to_sym] == nil }
				raise(ArgumentException.new(unk, 'Unknown action argument!')) if unk != nil
				
				plan.run(ctx, *args)
			end
		end
	end
end