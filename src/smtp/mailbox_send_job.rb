# Created by Matyáš Pokorný on 2019-06-19.

module ROM
	module SMTP
		class MailboxSendJob < Job
			def initialize(db, stg, id, addr)
				super("SMTP Submission of '#{addr}'")
				@db = db
				@stg = stg
				@id = id
			end
			
			def job_task(log)
				send = []
				smtp = nil
				
				@db.open(DB::RomDbContext) do |ctx|
					box = ctx.mailboxes.find(@id)
					if box.smtp == nil
						log.warning("No SMTP configured for box #{box.id}:'#{box.address}'! Stopping...")
						return
					end
					
					smtp = SMTPClient.new(box.smtp.host, box.smtp.port, box.smtp.user, box.smtp.password, box.smtp.protection&.moniker == DB::TypeProtection::TLS)
					
					type = ctx.mail_state_types.find { |i| i.moniker == DB::TypeMailState::OUTBOUND }
					ctx.mails.select { |i| (i.references > 0).and(i.mailbox == box).and(i.state == type) }.each do |mail|
						att = []
						ctx.attachments.select { |i| i.mail == mail }.each do |a|
							att << { :name => a.name, :file => a.file }
						end
						
						recv = []
						ctx.mail_participants.select { |i| i.mail == mail }.each do |join|
							recv << join.participant.tag
						end
						
						send << {
							:id => mail.id,
							:subject => mail.subject,
							:sender => mail.sender.tag,
							:recipients => recv,
							:file => mail.file,
							:attachments => att
						}
					end
				end
				
				mails = []
				send.each do |mail|
					att = []
					drop = false
					mail[:attachments].each do |at|
						unless @stg.exists?(at[:file])
							drop = true
							break
						end
						
						part = @stg.load(at[:file])
						att << SMTPAttachment.new(part[:content_type], at[:name], part.data)
					end
					
					drop = true unless @stg.exists?(mail[:file])
					if drop
						log.warning("Mail source file for #{mail[:id]} not found! Dropping...")
						next
					end
					
					part = @stg.load(mail[:file])
					hdr = part.headers
					hdr[:subject] = mail[:subject]
					hdr[:from] = mail[:sender]
					hdr[:to] = mail[:recipients]
					
					mails << SMTPMessage.new(part.data, *att, **hdr)
				end
				
				log.debug('Opening SMTP connection...')
				tries = 0
				while tries < 3
					begin
						smtp.open
					rescue Exception => ex
						log.error('SMTP connection failed to open!', ex)
						raise
					end
					begin
						while mails.length > 0
							m = mails.last
							smtp.send(m)
							mails.delete_at(mails.length - 1)
						end
						
						break
					rescue Exception => ex
						log.error('Failed to transmit mail!', ex)
					ensure
						smtp.close
						tries += 1
					end
				end
			end
		end
	end
end