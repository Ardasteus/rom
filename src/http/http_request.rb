module ROM
  module HTTP
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

      def query
        @query
      end

      def fragment
        @fragment
      end

      def stream
        @io
      end

      # Instantiates the {ROM::HTTPRequest} class
      # @param [stream] io Client stream from which the class extracts all the parts of HTTP request. The leftover is the content of the request.
      def initialize(io)
        @io = io
        @method, @path, @version = io.readline.split
        @query = @path.split('?')[1] if @path.include('?')
        @query = parse_query(@query)
        @fragment = @path.split('#')[1] if @path.include('#')
        @path = @path.split('?').first
        parse_headers(io)
      end

      # Parses headers using {stream} provided in the constructor
      # @param [stream] io Client stream that the method parses the headers from
      def parse_headers(io)
        @headers = {}
        loop do
          ln = io.readline
          break if ln.strip.chomp == ''
          header, value = ln.split
          header = header.gsub("_", "-").downcase.to_sym
          @headers[header] = value
        end
      end

      def parse_query(query)
        ret = {}

        query.split('&').each do |part|
          key, value = part.split('=')
          ret[URI::decode(key)] = URI::decode(value)
        end

        return ret
      end

      def [](header)
        @headers[header]
      end

      private :parse_headers, :parse_query
    end
  end
end