module ROM
  module HTTP
    module Methods
      class DeleteMethod < HTTPMethod
        def initialize(itc)
          super(itc)
          @name = "DELETE"
        end

        def resolve(http_request, input_serializer, output_serializer)
          request = http_request
          path = format_path(request.path)
          begin
            plan = @gateway.plan(*path.push(:delete))
            plan.run()
            http_content = HTTPContent.new(nil)
            response = HTTPResponse.new(StatusCode::NO_CONTENT, http_content)
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
