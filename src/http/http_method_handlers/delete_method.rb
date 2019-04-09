module ROM
  class DeleteMethod < HTTPMethod
    def initialize(itc)
      super(itc)
      @name = "DELETE"
    end

    def resolve(http_request, input_serializer, output_serializer)
      request = http_request
      path = format_path(request.path)
      #raise("This input type: '#{request[:content_type]}' is not supported !") if input_serializer == nil
      #raise("This output type: '#{request[:accepts]}' is not supported !") if output_serializer == nil
      begin
        plan = @gateway.plan(*path.push(:delete))
        value = plan.run()
        #response_content = input_serializer.from_object(value)
        #http_content = HTTPContent.new(response_content, :content_type => request[:accepts])
        http_content = HTTPContent.new(nil)
        response = HTTPResponse.new(StatusCode::OK, http_content)
      rescue Exception => ex
        http_content = HTTPContent.new(nil)
        response = HTTPResponse.new(StatusCode::NOT_FOUND, http_content)
      ensure
        return response
      end
    end
  end
end