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
            response = HTTPResponse.new(StatusCode::NO_CONTENT)
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
