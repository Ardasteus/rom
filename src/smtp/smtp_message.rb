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
        @body
      end

      def headers
        @message_headers
      end

      def attachments
        @attachments
      end

      def initialize(body, *attachments, **message_headers)
        @message_headers = message_headers
        @body = body
        @recipients = get_recipients(:to)
        @attachments = attachments
        @ccs = get_recipients(:cc)
        @sender = @message_headers[:from]
        if attachments != nil
          headers[:mime_version] = "1.0" if headers[:mime_version] == nil
          headers[:content_type] = 'multipart/mixed; boundary="X45R6q78 -8"' if headers[:content_type] == nil
        end
      end

      def get_recipients(hdr)
        recpts = []
        case @message_headers[hdr]
        when String
          recpts.push(@message_headers[hdr])
        when Array
          recpts_raw = @message_headers[hdr]
          recpts_raw.each do |recip|
            recpts.push(recip)
          end
        end

        return recpts
      end

      def [](hdr)
        return @message_headers[hdr]
      end

      def format_header(header)
        str = ""
        case @message_headers[header]
        when String
          str = header.to_s.split('_').collect(&:capitalize).join('-') + ": " + @message_headers[header]
          str = "MIME-Version: " + str.split.(": ")[1] if str.split.(": ")[0] == "Mime-Version"
        when Array
          val = @message_headers[header]
          str = header.to_s.split('_').collect(&:capitalize).join('-') + ": " + val.join(', ')
        end
        return str
      end

    end
  end
end