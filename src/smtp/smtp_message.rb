module ROM
  module SMTP
    class SMTPMessage

      def sender
        @sender
      end

      def recipients
        @recipients
      end

      def ccs
        @ccs
      end

      def body
        @message_body
      end

      def headers
        @message_headers
      end

      def initialize(body, **message_headers)
        @message_headers = message_headers
        @message_body = format_body(body)
        @recipients = get_recipients(:to)
        @ccs = get_recipients(:cc)
        @sender = @message_headers[:from]
      end

      def get_recipients(hdr)
        recpts = []
        recpts_raw = @message_headers[hdr]
        recpts_raw.each do |recip|
          recpts.push(recip)
        end
        return recpts
      end

      def [](hdr)
        return @message_headers[hdr]
      end

      def format_body(body)
        formatted = body.split("\n")
        formatted.push(".")
        return formatted
      end

      def format_header(header)
        case @message_headers[header]
        when String
          str = header.to_s + ": " + @message_headers[header]
        when Array
          val = @message_headers[header]
          str = header.to_s + ": "
          val.each do |part|
            str += part
          end

        end
      end

    end
  end
end