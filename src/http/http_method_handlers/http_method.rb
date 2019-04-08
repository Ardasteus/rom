module ROM
  class HTTPMethod
    include Component

    def initialize(itc)
      @itx = itc
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
  end
end