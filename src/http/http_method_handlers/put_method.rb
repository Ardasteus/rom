module ROM
  module HTTP
    module Methods
      class PutMethod < HTTPMethod
        def initialize(itc)
          super(itc)
          @name = "PUT"
        end

        def resolve(http_request, input_serializer, output_serializer)
          request = http_request
          path = format_path(request.path)
          raise("This input type: '#{request[:content_type]}' is not supported !") if input_serializer == nil
          begin
            plan = @gateway.plan(*path.push(:update))
            value = run_plan(plan, request, input_serializer)
            response_content = output_serializer.from_object(value)
            http_content = HTTPContent.new(response_content, :content_type => request[:accepts])
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
  end
end