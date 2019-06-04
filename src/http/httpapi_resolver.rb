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
          @header_filters = itc.lookup(Filters::HTTPHeaderFilter)
          itc.hook(Filters::HTTPHeaderFilter) do |filter|
            @header_filters.push(filter)
          end
        end

        # Resolves the given http request, fetching the correct {ROM::HTTP::Methods::HTTPMethod} and input/output {ROM::DataSerializers::Serializer} based on the http request headers
        # @param [ROM::HTTP::HTTPRequest] http_request HTTP request to resolve
        # @return [ROM:HTTP::HTTPResponse]
        def resolve(http_request)
          request = http_request
          begin
            method = @http_methods.select{|mtd| mtd.is_name(request.method)}.first
            return HTTPResponse.new(StatusCode::METHOD_NOT_ALLOWED) if method == nil
            input_serializer = @serializers.select{|srl| srl.is_content_type(request[:content_type])}.first
            return HTTPResponse.new(StatusCode::UNSUPPORTED_MEDIA_TYPE) if input_serializer == nil and request[:content_type] != nil
            output_serializer = @serializers.select{|srl| srl.is_content_type(request[:accepts])}.first
            return HTTPResponse.new(StatusCode::NOT_ACCEPTABLE) if output_serializer == nil and request[:accepts] != nil
            output_serializer = (output_serializer or @itc.fetch(DataSerializers::JSONSerializer))
            response = method.resolve(request, input_serializer, output_serializer)
          rescue
            response = HTTPResponse.new(StatusCode::BAD_REQUEST)
          end
          return response
      end
    end
  end
end