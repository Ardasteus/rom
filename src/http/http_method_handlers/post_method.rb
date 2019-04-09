module ROM
  module HTTP
    module Methods
      class PostMethod < HTTPMethod
        def initialize(itc)
          super(itc)
          @name = "POST"
        end

        def resolve(http_request, input_serializer, output_serializer)
          request = http_request
          path = format_path(request.path)
          raise("This input type: '#{request[:content_type]}' is not supported !") if input_serializer == nil
          begin
            begin
              plan = @gateway.plan(*path)
            rescue
              plan = @gateway.plan(*path.push(:create))
            end
            value = run_plan(plan, request, input_serializer)
            http_content = ObjectContent.new(value, output_serializer)
            response = HTTPResponse.new(StatusCode::CREATED, http_content)
          rescue Exception => ex
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