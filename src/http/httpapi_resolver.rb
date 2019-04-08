module ROM
  class HTTPAPIResolver
    include Component
    def initialize(itc)
      @gateway = itc.lookup(ApiGateway).first
      @serializers = itc.lookup(Serializer)
    end

    def resolve(http_request)
      request = http_request
      response = nil
      path = request.path
      path[0] = ''
      path = path.split('/')
      path = path.map{|part| part.to_sym}
      if request.method == "GET"
        begin
          plan = @gateway.plan(*path)
          plan = @gateway.plan(*path.push(:fetch)) unless plan != nil
          value = plan.run()
          serializer = @serializers.select{|srl| srl.is_content_type(request.headers[:accepts])}.first
          response_content = serializer.from_object(value)
          http_content = HTTPContent.new(response_content, :content_type => request.headers[:accepts])
          response = HTTPResponse.new(StatusCode::OK, http_content)
        rescue Exception => ex
        msg = ex.message
        #http_content = HTTPContent.new(StringIO.new(msg), :content_length => msg.length)
        http_content = HTTPContent.new(nil)
        response = HTTPResponse.new(StatusCode::NOT_FOUND, http_content)
        end

      elsif  request.method == "POST"
        begin
          plan = @gateway.plan(*path)
          plan = @gateway.plan(*path.push(:create)) unless plan != nil
          type = plan.signature.return_type
          serializer = @serializers.select{|srl| srl.is_content_type(request.headers[:content_type])}.first
          value = serializer.to_object(request.stream)
          value = type.from_object(value)
          plan.run(value)
          serializer = @serializers.select{|srl| srl.is_content_type(request.headers[:accepts])}.first
          response_content = serializer.from_object(value)
          http_content = HTTPContent.new(response_content, :content_type => request.headers[:accepts])
          response = HTTPResponse.new(StatusCode::OK, http_content)
        end
      end
      return response
    end
  end
end