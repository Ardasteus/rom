module ROM
	module SMTP
		class SMTPClient
			def initialize(host, port, username, password, tls = false)
				@host = host
				@port = port
				@username = username
				@password = password
				@tls = tls
				if block_given?
					open
					begin
						yield(self)
					ensure
						close
					end
				end
			end
			
			def ehlo
				command("EHLO #{@username}.#{@host}").lines.select { |i| i.downcase.start_with?('250') }.collect { |i| i[4..i.length].strip.downcase }
			end
			
			def open
				@client = TCPSocket.new(@host, @port)
				if @tls
					@client = OpenSSL::SSL::SSLSocket.new(@client, OpenSSL::SSL::SSLContext.new)
					@client.connect
				else
					pool_response(false)
					cbt = ehlo
					
					if cbt.include?('starttls')
						command('STARTTLS')
						@client = OpenSSL::SSL::SSLSocket.new(@client, OpenSSL::SSL::SSLContext.new)
						@client.connect
					end
				end
				auth = ehlo.find {|i| i.start_with?('auth')}&.split(' ').collect(&:downcase).drop(1)
				raise(Exception.new('Authentication, other than PLAIN, are not supported!')) if auth == nil or not auth.include?('plain')
				transmit('AUTH PLAIN')
				transmit(Base64.urlsafe_encode64("\0#{@username}\0#{@password}"), true)
			end
			
			def send(mail)
				command("MAIL FROM:" + mail.sender.split(" ")[-1])
				mail.recipients.each do |recp|
					command("RCPT TO:" + recp.split(" ")[-1])
				end
				command("DATA")
				mail.headers.each_key do |hdr|
					@client.puts(mail.format_header(hdr))
				end
				@client.puts
				send_body(mail) if mail.body != nil and mail.attachments.length == 0
				send_attachments(mail) if mail.attachments.length > 0
				transmit("\r\n.\r\n", true)
			end
			
			def close
				transmit('QUITS', true)
				@client.close
			end
			
			def pool_response(await = true)
				responses = []
				responses << @client.gets if await
				
				resp = nil
				responses.push(resp) while (resp = check_response) != nil
				
				responses.collect(&:strip).join($/)
			end
			
			def command(cmd)
				transmit(cmd, true)
			end
			
			def transmit(ln, resp = false)
				@client.puts(ln)
				pool_response if resp
			end
			
			def send_body(message)
				IO.copy_stream(message.body, @client)
			end
			
			def send_attachments(message)
				bounrady_raw = message[:content_type].split("; ")[1].split("=")[1]
				boundary = bounrady_raw.insert(0, "--")
				@client.puts(boundary)
				
				if message.body != nil
					@client.puts("Content-Type: text/plain")
					@client.puts("Content-Disposition: inline")
					@client.puts("Content-Description: text-part-1")
					@client.puts("Content-Transfer-Encoding: base64")
					@client.puts
					base64_send(message.body)
					@client.puts
				end
				
				message.attachments.each do |attachment|
					@client.puts(boundary)
					@client.puts("Content-Type: #{attachment.content_type}; name=" + '"' + attachment.name + '"')
					@client.puts("Content-Transfer-Encoding: base64")
					@client.puts("Content-Disposition: attachment; filename=" + '"' + attachment.name + '"')
					@client.puts
					@client.puts
					base64_send(attachment.data)
					@client.puts
					@client.puts
				end
				boundary << "-"
				boundary << "-"
				@client.puts(boundary)
			end
			
			def base64_send(io)
				bfr = nil
				@client.write(Base64.encode64(bfr)) while (bfr = io.read(3 * 64)) != nil and bfr.length > 0
			end
			
			def check_response
				buffer = ""
				buffer << @client.read_nonblock(1) while buffer[-1] != "\n"
				
				buffer
			rescue IO::WaitReadable, EOFError
				nil
			end
		end
	end
end