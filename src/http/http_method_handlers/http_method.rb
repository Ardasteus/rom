module ROM
  module HTTP
    module Methods
      class HTTPMethod
        include Component

        def initialize(itc)
          @itx = itc
					@gateway = itc.fetch(ApiGateway)
        end

        def resolve(http_request, input_serializer, output_serializer)

        end

        def is_name(method_name)
          @name == method_name
        end

        def format_path(input)
          path = input
          path[0] = ''
          path = path.split('/')
          path = path.map{|part| part.to_sym}
          return path
        end

        def run_plan(plan, request, serializer)
          args = []
          arg = plan.signature[0]
          if arg != nil
            if arg[:type].accepts(IO)
              args << request.stream
            elsif arg[:type].accepts(Model)
              args << serializer.to_object(request.stream.read)
            elsif arg[:required]
              raise("Unknown input argument type !")
            end
          end
          plan.run(*args)
        end
      end
    end
  end
end