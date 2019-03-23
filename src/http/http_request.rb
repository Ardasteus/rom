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

    # Instantiates the {ROM::HTTPRequest} class
    # @param [stream] io Client stream from which the class extracts all the parts of HTTP request. The leftover is the content of the request.
    def initialize(io)
      @io = io
      @method, @path, @version = io.readline.split
      parse_headers(io)
    end

    # Parses headers using {stream} provided in the constructor
    # @param [stream] io Client stream that the method parses the headers from
    def parse_header(io)
      @headers = {}
      loop do
        ln = io.readline
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