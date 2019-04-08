module ROM
  class GetMethod < HTTPMethod
    def initialize(itc)
      super(itc)
      @name = "GET"
    end

    def resolve(http_request, input_serializer, output_serializer)
      request = http_request
      path = format_path(request.path)
      begin
        plan = @gateway.plan(*path)
        plan = @gateway.plan(*path.push(:fetch)) unless plan != nil
        value = plan.run()
        response_content = input_serializer.from_object(value)
        http_content = HTTPContent.new(response_content, :content_type => request.headers[:accepts])
        response = HTTPResponse.new(StatusCode::OK, http_content)
      rescue Exception => ex
        http_content = HTTPContent.new(nil)
        response = HTTPResponse.new(StatusCode::NOT_FOUND, http_content)
      end
      return response
    end
  end
end