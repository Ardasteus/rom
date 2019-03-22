module ROM
  class HTTPRequest
    def method
      @method
    end

    def path
      @path
    end

    def version
      @version
    end

    def stream
      @io
    end

    def initialize(io)
      @io = io
      @method, @path, @version = io.readline.split
      parse_headers(io)
    end

    def parse_headers(http_request)
      @headers = {}
      loop do
        ln = http_request.readline
        break if ln.strip.chomp == ''
        header, value = ln.split
        header = header.gsub("_", "-").downcase.to_sym
        @headers[header] = value
      end
    end

    def [](header)
      header[header]
    end
  end
end