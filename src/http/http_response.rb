module ROM
  class HTTPResponse
    def response
      @response
    end

    def initialize(code:, data: "")
        @response =
            "HTTP/1.1 #{code}\r\n" +
                "Content-Length: #{data.size}\r\n" +
                "\r\n" +
                "#{data}\r\n"
    end
  end
end