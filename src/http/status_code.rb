module ROM
  module HTTP

    # Class encapsuling the number and text of the HTTP response status codes. Used to create constants
    class StatusCode

      # Status code number
      # @return [Integer]
      def code
        @code
      end

      # Text of the status code
      # @return [String]
      def note
        @note
      end

      # Instantiates the {ROM::HTTP::StatusCode} class
      # @param [Integer] code Status code number
      # @param [String] text Text of the status code
      def initialize(code, text)
        @code = code
        @note = text
      end

      # Converts the status code into a string format
      def to_s
        "#{@code} #{@note}"
      end

      CONTINUE            = self.new(100, "Continue")
      SWITCHING_PROTOCOLS = self.new(101, "Switching Protocols")
      OK                  = self.new(200, "OK")
      CREATED             = self.new(201, "Created")
      MOVED_PERMANENTLY   = self.new(301, "Moved Permanently")
      BAD_REQUEST         = self.new(400, "Bad Request")
      NOT_FOUND           = self.new(404, "Not Found")
      NO_CONTENT           = self.new(204, "No Content")
    end
  end
end