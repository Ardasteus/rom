module ROM
  module HTTP
    module Methods

      # Class that handles all DELETE HTTP requests
      class DeleteMethod < HTTPMethod

        # Instantiates the {ROM::HTTP::Methods::HTTPMethod} class
        # @param [ROM::Interconnect] itc Interconnect
        def initialize(itc)
          super(itc)
          @name = "DELETE"
        end

        # Resolves the given http request and formats the content with the given input/output serializers
        # @param [ROM::HTTP::HTTPRequest] http_request HTTP request to resolve
        # @param [ROM::DataSerializers::Serializer] input_serializer Input serializer, based on the Content-Type header. Not required
        # @param [ROM::DataSerializers::Serializer] output_serializer Output serializer, based on the Accepts header, defaults to {ROM::DataSerializers::JSONSerializer}. Not required
        def resolve(http_request, input_serializer, output_serializer)
          request = http_request
          path = format_path(request.path)
          begin
            plan = @gateway.plan(*path.push(:delete))
            plan.run()
            response = HTTPResponse.new(StatusCode::NO_CONTENT)
          rescue Exception => ex
            response = HTTPResponse.new(StatusCode::NOT_FOUND)
          ensure
            return response
          end
        end
      end
    end
  end
end
