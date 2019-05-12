module ROM
  module HTTP
    module Methods

      # Base class for all HTTP method handlers
      class HTTPMethod
        include Component

        # Instantiates the {ROM::HTTP::Methods::HTTPMethod} class
        # @param [ROM::Interconnect] itc Interconnect
        def initialize(itc)
          @itx = itc
					@gateway = itc.fetch(ApiGateway)
        end

        # Resolves the given http request and formats the content with the given input/output serializers
        # @param [ROM::HTTP::HTTPRequest] http_request HTTP request to resolve
        # @param [ROM::DataSerializers::Serializer] input_serializer Input serializer, based on the Content-Type header
        # @param [ROM::DataSerializers::Serializer] output_serializer Output serializer, based on the Accepts header, defaults to {ROM::DataSerializers::JSONSerializer}
        def resolve(http_request, input_serializer, output_serializer)
        end

        # Checks if the given method is corresponding to the method of [HTTPMethod] class
        # @return [Boolean]
        def is_name(method_name)
          @name == method_name
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
        def run_plan(plan, request, serializer, ctx = ApiContext.new)
          args = []
          arg = plan.signature[0]
          if arg != nil
            if arg[:type].accepts(IO)
              args << request.stream
            elsif arg[:type].accepts(Model)
              args << serializer.to_object(request.stream.read)
            elsif arg[:required]
              raise("Unknown input argument type !")
            end
          end
          plan.run(ctx, *args)
        end
      end
    end
  end
end