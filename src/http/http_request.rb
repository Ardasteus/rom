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

    def initialize(http_request, io)
      @method, @path, @version = http_request.lines[0].split
      @io = io
      parse_headers(http_request)
    end

    def parse_headers(http_request)
      @headers = {}
      http_request.lines[1..-1].each do |line|
        header, value = line.split
        header = header.gsub("_", "-").downcase.to_sym
        headers[header] = value
      end
    end

    def [](header)
      header[header]
    end
  end
end