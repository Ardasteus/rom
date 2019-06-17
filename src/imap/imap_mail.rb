module ROM
  module IMAP
    class IMAPMail
      def initialize(headers, data, attachment)
        @headers =  headers
        @data =  data
        @attachments = attachment
      end


    end
  end
end