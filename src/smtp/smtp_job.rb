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
        @client = TCPSocket.new("mail.sssvt.cz", 25)
        check_response
        send_data("EHLO " + @user + "sssvt.cz")
        send_data("STARTTLS")
        @client = OpenSSL::SSL::SSLSocket.new(@client, OpenSSL::SSL::SSLContext.new())
        @client.connect
        send_data("EHLO " + @user + "sssvt.cz")
        send_data("AUTH PLAIN")
        send_await(Base64.urlsafe_encode64("\0#{@user}\0#{@pass}"))
        send_data("MAIL FROM:" + @message.sender.split(" ")[-1])
        send_recipients
        send_data("DATA")
        send_headers
        send_body
        @client.puts("QUITS")
        puts "QUITS"
        resp = @client.gets
        puts resp
      end

      def send_data(string)
        puts string
        @client.puts(string)
        responses = []
        resp = @client.gets
        responses.push(resp) if resp != nil
        resp = check_response while resp != nil
        responses.push(resp) if resp != nil
        puts responses
        return responses  
      end


      def send_await(string)
        puts string
        @client.puts(string)
        responses = []
        resp = await_response
        responses.push(resp) if resp != nil
        resp = check_response while resp != nil
        responses.push(resp) if resp != nil
        puts responses
        return responses
      end

      def send_recipients
        @message.recipients.each do |recp|
          send_data("RCPT TO:" + recp.split(" ")[-1])
        end
      end

      def await_response
        resp = nil
        resp = check_response while resp == nil
        return resp
      end

      def check_response
        buffer = ""
        buffer << @client.read_nonblock(1) while buffer[-1] != "\n"
        puts buffer
        return buffer
          #code = buffer.split(" ")[0]
          #true if (code == "250" || code == "334" || code == "354" || code == "221" || code == "235")
      rescue IO::WaitReadable
        nil
      end

      def send_headers
        puts @message.headers.inspect
        @message.headers.each_key do |hdr|
          puts @message.format_header(hdr)
          @client.puts(@message.format_header(hdr))
        end
        puts
        @client.puts
      end

      def send_body
        puts @message.body_raw
        @client.puts(@message.body_raw)
        send_data("\r\n.\r\n")
      end
    end
  end
end