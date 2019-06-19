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
        send_recipients(@message)
        send_data("DATA")
        send_headers(@message)
        send_body(@message) if @message.body != nil && @message.attachments == nil
        send_attachments(@message) if @message.attachments != nil
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

      def send_recipients(message)
        message.recipients.each do |recp|
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

      def send_headers(message)
        puts message.headers.inspect
        message.headers.each_key do |hdr|
          puts message.format_header(hdr)
          @client.puts(message.format_header(hdr))
        end
        puts
        @client.puts
      end

      def send_body(message)
        puts message.body
        @client.puts(message.body)
        send_data("\r\n.\r\n")
      end

      def send_attachments(message)
        delimeter_raw = message[:content_type].split("; ")[1].split("=")[1]
        delimeter = delimeter_raw.insert(0, "--")
        puts delimeter
        @client.puts(delimeter)

        if message.body != nil
          puts "Content-Type: text/plain"
          @client.puts("Content-Type: text/plain")
          puts "Content-Disposition: inline"
          @client.puts("Content-Disposition: inline")
          puts "Content-Description: text-part-1"
          @client.puts("Content-Description: text-part-1")
          puts "\r\n"
          @client.puts("\r\n")
          puts message.body
          @client.puts(message.body)
          puts "\r\n"
          @client.puts("\r\n")
        end

        message.attachments.each do |attachment|
          puts delimeter
          @client.puts(delimeter)
          puts "Content-Type: #{attachment.content_type}; name=" + '"' + attachment.name + '"'
          @client.puts("Content-Type: #{attachment.content_type}; name=" + '"' + attachment.name + '"')
          puts "Content-Transfer-Encoding: base64"
          @client.puts("Content-Transfer-Encoding: base64")
          puts "Content-Disposition: attachment; filename=" + '"' + attachment.name + '"'
          @client.puts("Content-Disposition: attachment; filename=" + '"' + attachment.name + '"')
          puts "\r\n"
          @client.puts("\r\n")
          puts Base64.urlsafe_encode64(attachment.data)
          puts "\r\n"
          @client.puts("\r\n")
          @client.puts(Base64.urlsafe_encode64(attachment.data))
          puts "\r\n"
          @client.puts("\r\n")
        end
        delimeter << "-"
        delimeter << "-"
        puts delimeter
        @client.puts(delimeter)
        send_data("\r\n.\r\n")
      end
    end
  end
end