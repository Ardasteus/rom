module ROM
  class PutMethod < HTTPMethod
    def initialize(itc)
      super(itc)
      @name = "PUT"
    end

    def resolve(http_request, input_serializer, output_serializer)
      request = http_request
      raise("This input type: '#{request[:content_type]}' is not supported !") if input_serializer == nil
      #raise("This output type: '#{request[:accepts]}' is not supported !") if output_serializer == nil
      begin
      path = format_path(request.path)
      plan = @gateway.plan(*path.push(:update))
      type = plan.signature.return_type
      value = input_serializer.to_object(request.stream)
      value = type.from_object(value)
      plan.run(value)
      #response_content = output_serializer.from_object(value)
      #http_content = HTTPContent.new(response_content, :content_type => request[:accepts])
      http_content = HTTPContent.new(nil)
      response = HTTPResponse.new(StatusCode::OK, http_content)
      rescue
        http_content = HTTPContent.new(nil)
        response = HTTPResponse.new(StatusCode::NOT_FOUND, http_content)
      ensure
        return response
      end
    end
  end
end