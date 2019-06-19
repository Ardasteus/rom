module ROM
	module SMTP
		class SMTPAttachment
			def content_type
				@content_type
			end
			
			def name
				@name
			end
			
			def data
				@data
			end
			
			def initialize(content_type, name, data)
				@content_type = content_type
				@name = name
				@data = data
			end
		end
	end
end