module ROM
  module HTTP

    # Class that handles the routing of HTTP calls into API calls
    class HTTPAPIResolver
      include Component

      # Instantiates the {ROM::HTTP::HTTPAPIResolver} class
      # @param [ROM::Interconnect] itc Interconnect
      def initialize(itc)
        @itc = itc
        @gateway = itc.fetch(ApiGateway)
        @serializers = itc.lookup(DataSerializers::Serializer)
        itc.hook(DataSerializers::Serializer) do |serializer|
          @serializers.push(serializer)
        end
        @http_methods = itc.lookup(Methods::HTTPMethod)
        itc.hook(Methods::HTTPMethod) do |method|
          @http_methods.push(method)
        end
      end

      # Resolves the given http request, fetching the correct {ROM::HTTP::Methods::HTTPMethod} and input/output {ROM::DataSerializers::Serializer} based on the http request headers
      # @param [ROM::HTTP::HTTPRequest] http_request HTTP request to resolve
      # @return [ROM:HTTP::HTTPResponse]
      def resolve(http_request)
        request = http_request

        begin
          method = @http_methods.select{|mtd| mtd.is_name(request.method)}.first
          raise("Method '#{request.method}' is not supported !") if method == nil
          input_serializer = @serializers.select{|srl| srl.is_content_type(request[:content_type])}.first
          output_serializer = @serializers.select{|srl| srl.is_content_type(request[:accepts])}.first
          output_serializer = (output_serializer or @itc.fetch(DataSerializers::JSONSerializer))
          response = method.resolve(request, input_serializer, output_serializer)
        rescue
          http_content = HTTPContent.new(nil)
          response = HTTPResponse.new(StatusCode::BAD_REQUEST, http_content)
        end
        return response
      end
    end
  end
end