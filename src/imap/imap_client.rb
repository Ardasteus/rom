module ROM
  module IMAP
    class IMAPClient
      def intialize(host, port, username, password, tls = false)
        @host = host
        @port = port
        @username = username
        @password = password
        @tls = tls
        @counter = 1
      end

      def open
        if !@tls
          @client = TCPSocket.new(@server, @port)
          handle_response
          send_data("STARTTLS")
          @client = OpenSSL::SSL::SSLSocket.new(@client, OpenSSL::SSL::SSLContext.new())
          handle_response
          @client.connect
        else
          @client = OpenSSL::SSL::SSLSocket.new(TCPSocket.new(@server, @port), OpenSSL::SSL::SSLContext.new())
          handle_response
          @client.connect
        end
        send_data("LOGIN #{@user} #{@password}")
      end

      def mailboxes
        raw = send_data('LIST "" %')
        @mailboxes = []
        raw.each do |folder|
          @mailboxes.push(folder.split('"')[3].tr('"', ''))
        end
      end

      def select(mailbox)
        send_data("SELECT " + mailbox)
      end

      def list(date)
        mails = []
        string = 'SEARCH SINCE "' + date.strftime('%d-%b-%Y')  + '" BEFORE "' + Time.new.strftime("%d-%b-%Y")+ '"'
        responses = send_data(string)
        responses = responses[0].split(" ")
        responses.shift(2)
        responses.each do |mail|
          mails.push(mail.to_i)
        end
        return mails
      end

      def fetch(id)
        string = "#{@counter} FETCH #{id} RFC822.HEADER"
        @counter += 1
        puts string
        @client.puts(string)

        headers = {}
        responses = []
        @client.gets
        resp = ""
        while resp != nil
          resp = handle_response
          responses.push(resp) if resp != nil
        end
        responses.pop(3)
        oldkey = nil
        responses.each do |response|
          if response[0] == "\t"
            response = response.tr("\r\n", "").tr("\t", "")
            if headers[oldkey].is_a?(Array)
              headers[oldkey] << response
            else
              vals = []
              vals.push(headers[oldkey])
              headers[oldkey] = vals
            end
          elsif response[0] == " "
            response = response.tr("\r\n", "").tr("\t", "").tr(" ","")
            if headers[oldkey].is_a?(Array)
              headers[oldkey] << response
            else
              vals = []
              vals.push(headers[oldkey])
              headers[oldkey] = vals
            end
          else
            newkey, value = response.split(": ")
            value = value.tr("\r\n", "")
            value = value.tr("\t", "")
            newkey = newkey.to_sym
            oldkey = newkey
            headers[newkey] = value
          end
        end

        #TODO: FIX-IT, loop via delimeters, vulnerable to "Content-Type: "
        string = "#{@counter} FETCH #{id} RFC822.TEXT"
        @counter += 1
        puts string
        @client.puts(string)
        responses = []
        response = ""
        temp = @client.gets
        first = true
        data = []
        current = nil
        old_key = nil
        first_n = false
        data.push(current)
        data.inspect
        while response != nil
          response = handle_response
          if first == true && response == "\r\n"
            response = handle_response
            first = false
          end
          #responses.push(resp) if (resp != nil && (resp[0] != "-" && resp[1] != "-"))
          if response != nil && (response[0] != "-" && response[1] != "-")

            key, value = response.split(": ")
            if key == "Content-Type"
              if current == nil
                current = IMAPMailData.new
                value = value.tr("\r\n", "")
                current.headers[key.to_sym] = value
                old_key = key.to_sym
              else
                current.data = current.data[0..-5]
                data.push(current)
                first_n = false
                current = IMAPMailData.new
                value = value.tr("\r\n", "")
                current.headers[key.to_sym] = value
                old_key = key.to_sym
              end
            elsif response[0] == "\t"
              if current.data == ""
                response.tr("\t", "").tr("\r\n", "")
                current.headers[old_key] = current.headers[old_key] + response
              else
                current.data = current.data + response
              end
            elsif response == "\r\n"
              if current.data != ""
                current.data = current.data + response
              else
                first_n = true
              end
            elsif value == nil
              if current == nil
                current = IMAPMailData.new
                current.headers["Content-Type".to_sym] = "plain/text"
                current.data = current.data + response
                first_n = true
              elsif current.data == ""
                if first_n == true
                  current.data = current.data + response
                else
                  response.tr("\t", "").tr("\r\n", "")
                  current.headers[old_key] = current.headers[old_key] + response
                end
              else
                current.data = current.data + response
              end
            elsif first_n == false
              value = value.tr("\r\n", "")
              current.headers[key.to_sym] = value
              old_key = key.to_sym
            else
              current.data = current.data + response
            end
          end
        end
        #responses.pop(3)
        #responses.shift if responses[0] == "\r\n"
        #responses.each do |response|
        #end
        current.data = current.data[0..-32]
        data.push(current)
        #puts data.inspect
        mail = IMAPMail.new(headers, data, nil)
      end

      def send_data(string)
        string = "#{@counter} #{string}"
        @counter += 1
        puts string
        @client.puts(string)
        responses = []
        resp = @client.gets
        responses.push(resp) unless resp == nil
        while resp != nil
          resp = handle_response
          responses.push(resp)
        end
        puts responses
        return responses
      end

      def handle_response
        buffer = ""
        buffer << @client.read_nonblock(1) while buffer[-1] != "\n"
        puts buffer
        return buffer
      rescue IO::WaitReadable
        nil
      end
    end
  end
end