module ROM
  module HTTP
    module Methods
      class GetMethod < HTTPMethod
        def initialize(itc)
          super(itc)
          @name = "GET"
        end

        def resolve(http_request, input_serializer, output_serializer)
          request = http_request
          path = format_path(request.path)
          begin
            begin
              plan = @gateway.plan(*path)
            rescue Exception => ex
              plan = @gateway.plan(*path.push(:fetch))
            end
            value = run_plan(plan, request, input_serializer)
            http_content = ObjectContent.new(value, output_serializer)
            response = HTTPResponse.new(StatusCode::OK, http_content)
          rescue Exception => ex
            response = HTTPResponse.new(StatusCode::NOT_FOUND)
          ensure
            return response
          end
        end
      end
    end
  end
end