module ROM
  module IMAP
    class IMAPJob < Job

      def initialize(user, password, server, port)
        @server = server
        @port = port
        @user = user
        @password = password
        @counter = 1
      end

      def job_task(log)
        @client = TCPSocket.new(@server, @port)
        handle_response
        send_data("STARTTLS")
        @client = OpenSSL::SSL::SSLSocket.new(@client, OpenSSL::SSL::SSLContext.new())
        @client.connect
        send_data("CAPABILITY")
        send_data("LOGIN #{@user} #{@password}")
        send_data('SELECT "INBOX"')
        fetch_mail(695)
      end

      def send_data(string)
        string = "#{@counter} #{string}"
        @counter += 1
        puts string
        @client.puts(string)
        responses = []
        resp = @client.gets
        responses.push(resp) if resp != nil
        responses.push(handle_response) while handle_response != nil
        puts responses
        return responses
      end

      def handle_response
        buffer = ""
        buffer << @client.read_nonblock(1) while buffer[-1] != "\n"
        #buffer = buffer.tr("\r\n", "")
        #buffer = buffer.tr("\t", "")
        puts buffer
        return buffer
          #code = buffer.split(" ")[0]
          #true if (code == "250" || code == "334" || code == "354" || code == "221" || code == "235")
      rescue IO::WaitReadable
        nil
      end

      def await_response
        resp = nil
        resp = handle_response while resp == nil
        return resp
      end

      def fetch_mail(id)
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
            response = response.tr("\r\n", "")
            response = response.tr("\t", "")
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

        string = "#{@counter} FETCH #{id} RFC822.TEXT"
        @counter += 1
        puts string
        @client.puts(string)
        responses = []
        resp = ""
        @client.gets
        while resp != nil
          resp = handle_response
          responses.push(resp.tr("\r\n", "")) if (resp != nil && resp != "\r\n" && (resp[0] != "-" && resp[1] != "-"))
        end
        responses.pop(2)
        data = []
        current = nil
        responses.each do |response|
          key, value = response.split(": ")
          if key == "Content-Type"
            val1, val2 = value.split("; ")
            if val1.split("/")[0] != "multipart"
              data.push(current) if current != nil
              current = IMAPMailData.new(val1)
            end
          elsif value == nil
            current.data = current.data + key
          else
            current.headers[key.to_sym] = value
          end
        end
        data.push(current)
        data.inspect
      end

    end
  end
end