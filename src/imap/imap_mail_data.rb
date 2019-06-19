module ROM
  module IMAP
    class IMAPMailData

      def content_type
        @content_type
      end

      def headers
        @headers
      end

      def data
        return @data
      end

      def data=(data)
        @data = data
      end

      def initialize()
        @headers = {}
        @data = ""
      end
    end
  end
end