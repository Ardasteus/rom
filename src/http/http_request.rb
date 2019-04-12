module ROM
  module HTTP

    # Class that encapsulates a HTTP request
    class HTTPRequest

      # Method of the HTTP request
      # @return [String]
      def method
        @method
      end

      # Path of the HTTP request
      # @return [String]
      def path
        @path
      end

      # HTTP version of the request
      # @return [String]
      def version
        @version
      end

      # Hash of all queries
      # @return [Hash]
      def query
        @query
      end

      # Fragment of the HTTP request
      # @return [String]
      def fragment
        @fragment
      end

      # Content of the HTTP request
      # @return [IO]
      def stream
        @io
      end

      # Instantiates the {ROM::HTTPRequest} class
      # @param [stream] io Client stream from which the class extracts all the parts of HTTP request. The leftover is the content of the request.
      def initialize(io)
        @io = io
        @method, @path, @version = io.readline.split
        @query = @path.split('?')[1] if @path.include?('?')
        @query = parse_query((@query or ''))
        @fragment = @path.split('#')[1] if @path.include?('#')
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

      # Parses the query into a hash containing all queries
      # @param [String] query Query to parse
      def parse_query(query)
        ret = {}

        query.split('&').each do |part|
          key, value = part.split('=')
          ret[URI::decode(key)] = URI::decode(value)
        end

        return ret
      end

      # Gets the header specified by its name
      # @param [Symbol] header Symbol defining the name of the header
      def [](header)
        @headers[header]
      end

      private :parse_headers, :parse_query
    end
  end
end