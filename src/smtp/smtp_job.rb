module ROM
  module SMTP
    class SMTPJob < ROM::Job

      def initialize(smtp_message, server, port, user, pass)
        @message = smtp_message
        @server = server
        @port = port
        @user = user
        @pass = pass
      end

      def job_task(log)
        @client = OpenSSL::SSL::SSLSocket.new(@server, @port)
        check_response
        send_data("EHLO " + @server)
        send_data("AUTH LOGIN")
        send_data(Base64.urlsafe_encode64(@user))
        send_data(Base64.urlsafe_encode64(@pass))
        send_data("MAIL FROM " + @message.sender.split(" ")[-1])
        send_recipients
        send_data("DATA")
        send_headers
        send_body
        send_data("QUITS")
      end

      def send_data(string)
        @client.write(string)
        resp = check_response
        resp = check_response while resp != nil
      end


      def send_recipients
        @message.recipients.each do |recp|
          send_data("RCPT " + recp.split(" ")[-1])
        end
      end

      def check_response
        buffer = ""
        buffer << read_nonblock(1) while buffer[-1] != "\n"
        code = buffer.split(" ")[0]
        true if (code == "250" || code == "334" || code == "354" || code == "221" || code == "235")
      rescue
        nil
      end

      def send_headers
        @message.headers.keys do |hdr|
          send(@message.format_header(hdr))
        end
        send_data(" ")
      end

      def send_body
        @message.body.each do |part|
          send_data(part)
        end
        check_response
      end
    end
  end
end