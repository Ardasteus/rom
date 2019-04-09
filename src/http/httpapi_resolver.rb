module ROM
  class HTTPAPIResolver
    include Component
    def initialize(itc)
      @gateway = itc.lookup(ApiGateway).first
      @serializers = itc.lookup(Serializer)
      itc.hook(Serializer) do |serializer|
        @serializers.push(serializer)
      end
      @http_methods = itc.lookup(HTTPMethod)
      itc.hook(HTTPMethod) do |method|
        @http_methods.push(method)
      end
    end

    def resolve(http_request)
      request = http_request

      begin
        method = @http_methods.select{|mtd| mtd.is_name(request.method)}.first
        raise("Method '#{request.method}' is not supported !") if method == nil
        input_serializer = @serializers.select{|srl| srl.is_content_type(request[:content_type])}.first
        output_serializer = @serializers.select{|srl| srl.is_content_type(request[:accepts])}.first
        response = method.resolve(request, input_serializer, output_serializer)
      rescue
        http_content = HTTPContent.new(nil)
        response = HTTPResponse.new(StatusCode::BAD_REQUEST, http_content)
      ensure
        return response
      end
    end
  end
end