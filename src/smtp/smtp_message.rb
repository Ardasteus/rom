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
				
				recpts
			end
			
			def [](hdr)
				@message_headers[hdr]
			end
			
			def format_header(header)
				key = header.to_s.split('_').collect(&:capitalize).join('-') + ": "
				case @message_headers[header]
					when String, Integer
						str = key + @message_headers[header].to_s
						
						str = "MIME-Version: " + str.split(': ')[1] if header == :mime_version
						
						str
					when Array
						val = @message_headers[header]
						
						key + val.join(', ')
					else
						raise('Invalid header value!')
				end
			end
		end
	end
end