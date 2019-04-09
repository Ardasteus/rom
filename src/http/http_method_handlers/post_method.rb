module ROM
  class PostMethod < HTTPMethod
    def initialize(itc)
      super(itc)
      @name = "POST"
    end

    def resolve(http_request, input_serializer, output_serializer)
      request = http_request
      raise("This input type: '#{request[:content_type]}' is not supported !") if input_serializer == nil
      raise("This output type: '#{request[:accepts]}' is not supported !") if output_serializer == nil
      path = format_path(request.path)
      plan = @gateway.plan(*path)
      plan = @gateway.plan(*path.push(:create)) if plan == nil
      type = plan.signature.return_type
      value = input_serializer.to_object(request.stream)
      value = type.from_object(value)
      plan.run(value)
      response_content = output_serializer.from_object(value)
      http_content = HTTPContent.new(response_content, :content_type => request[:accepts])
      response = HTTPResponse.new(StatusCode::CREATED, http_content)
      return response
    end
  end
end