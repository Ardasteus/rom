module ROM
  module SMTP
    class SMTPClient
      def initialize(host, port, username, password, tls = false)
        @host = host
        @port = port
        @username = username
        @password = password
        @tls = tls
      end

      def open
        if !@tls
          @client = TCPSocket.new(@host, @port)
          check_response
          send_data("EHLO #{@username}.#{@host}")
          send_data("STARTTLS")
          @client = OpenSSL::SSL::SSLSocket.new(@client, OpenSSL::SSL::SSLContext.new())
          @client.connect
          send_data("EHLO #{@username}.#{@host}")
        else
          @client = OpenSSL::SSL::SSLSocket.new(TCPSocket.new(@host, @port), OpenSSL::SSL::SSLContext.new())
          @client.connect
          send_data("EHLO #{@username}.#{@host}")
        end
        send_data("AUTH PLAIN")
        send_await(Base64.urlsafe_encode64("\0#{@username}\0#{@password}"))
      end

      def send(mail)
        send_data("MAIL FROM:" + @message.sender.split(" ")[-1])
        mail.recipients.each do |recp|
          send_data("RCPT TO:" + recp.split(" ")[-1])
        end
        send_data("DATA")
        mail.headers.each_key do |hdr|
          puts mail.format_header(hdr)
          @client.puts(mail.format_header(hdr))
        end
        @client.puts
        send_body(mail) if mail.body != nil && mail.attachments == []
        send_attachments(mail) if mail.attachments != nil
      end

      def close
        @client.puts("QUITS")
        @client.gets
        @client.close
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

      def send_body(message)
        puts message.body
        @client.puts(message.body)
        send_data("\r\n.\r\n")
      end

      def send_attachments(message)
        bounrady_raw = message[:content_type].split("; ")[1].split("=")[1]
        boundary = bounrady_raw.insert(0, "--")
        puts boundary
        @client.puts(boundary)

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
          puts boundary
          @client.puts(boundary)
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
        boundary << "-"
        boundary << "-"
        puts boundary
        @client.puts(boundary)
        send_data("\r\n.\r\n")
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
    end
  end
end