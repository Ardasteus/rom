module ROM
  class HTTPAPIResolver
    include Component
    def initialize(itc)
      @gateway = itc.lookup(ApiGateway).first
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
          if http_request[:accepts] == "application/json"
            json_string = JSON.generate(value.to_object)
            http_content = HTTPContent.new(StringIO.new(json_string), :content_type => "application/json" ,:content_length => json_string.length)
            response = HTTPResponse.new(StatusCode::OK, http_content)
          end
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
          if http_request[:content_type] == "application/json"
            value = JSON.parse(request.stream)
            value = type.from_object(value)
            plan.run(value)
            json_string = JSON.generate(value.to_object)
            http_content = HTTPContent.new(StringIO.new(json_string), :content_type => "application/json" ,:content_length => json_string.length)
            response = HTTPResponse.new(StatusCode::OK, http_content)
          end
        end
      end
      return response
    end
  end
end