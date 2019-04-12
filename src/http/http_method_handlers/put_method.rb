module ROM
  module HTTP
    module Methods

      # Class that handles all PUT HTTP requests
      class PutMethod < HTTPMethod

        # Instantiates the {ROM::HTTP::Methods::PutMethod} class
        # @param [ROM::Interconnect] itc Interconnect
        def initialize(itc)
          super(itc)
          @name = "PUT"
        end

        # Resolves the given http request and formats the content with the given input/output serializers
        # @param [ROM::HTTP::HTTPRequest] http_request HTTP request to resolve
        # @param [ROM::DataSerializers::Serializer] input_serializer Input serializer, based on the Content-Type header
        # @param [ROM::DataSerializers::Serializer] output_serializer Output serializer, based on the Accepts header, defaults to {ROM::DataSerializers::JSONSerializer}
        def resolve(http_request, input_serializer, output_serializer)
          request = http_request
          path = format_path(request.path)
          raise("This input type: '#{request[:content_type]}' is not supported !") if input_serializer == nil
          begin
            plan = @gateway.plan(*path.push(:update))
            value = run_plan(plan, request, input_serializer)
            http_content = ObjectContent.new(value, output_serializer)
            response = HTTPResponse.new(StatusCode::OK, http_content)
          rescue
            response = HTTPResponse.new(StatusCode::NOT_FOUND)
          ensure
            return response
          end
        end
      end
    end
  end
end