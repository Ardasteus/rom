# Created by Matyáš Pokorný on 2019-06-18.

module ROM
	module API
		class MailsResource < Resource
			class MailShortModel < Model
				property! :id, Integer
				property! :subject, String
				property! :date, String
				property! :sender, String
				property! :state, String
				property! :read, Types::Boolean[]
				property! :attachments, Integer
			end
			
			def initialize(db, col)
				@db = db
				@col = col
			end
			
			def close(tail)
				@db.close if tail
			end
			
			class MailResource < Resource
				class AttachmentModel < Model
					property! :id, Integer
					property! :name, String
					property! :type, String
					property! :size, Integer
				end
				
				class ParticipantModel < Model
					property :name, String
					property! :address, String
					property :contact, Integer
					property :user, Integer
					
					def self.from_db(db, e)
						contact = e.contact
						user = contact != nil ? db.users.find { |i| i.contact == contact } : nil
						ParticipantModel.new(:name => e.name, :address => e.address, :contact => contact&.id, :user => user&.id)
					end
				end
				
				class MailModel < Model
					property! :subject, String
					property! :date, String
					property! :sender, ParticipantModel
					property! :state, String
					property! :excerpt, String
					property! :read, Types::Boolean[]
					property! :size, Integer
					property! :attachments, Types::Array[AttachmentModel]
					property! :recipients, Types::Array[ParticipantModel]
				end
				
				def initialize(db, link)
					@db = db
					@link = link
					@mail = link.mail
				end
				
				def close(tail)
					@db.close if tail
				end
				
				class BodyResource < Resource
					def initialize(db, mail)
						@db = db
						@mail = mail
					end
					
					def close(tail)
						@db.close if tail
					end
					
					action :fetch, MimeStream, AuthorizeAttribute[] do
						stg = interconnect.fetch(MailStorage)
						raise(NotFoundException.new('Mail file not found!')) unless @mail.file != nil and stg.exists?(@mail.file)
						part = stg.load(@mail.file)
						
						MimeStream.new(part[:content_type], BoundedIO.new(part.data, part[:content_length]))
					end
					
					action :update, Types::Void, AuthorizeAttribute[], :body! => MimeStream do |body|
						raise(InvalidOperationException.new('Only drafts can be edited!')) unless @mail.state.moniker == DB::TypeStates::DRAFT
						stg = interconnect.fetch(MailStorage)
						
						old = @mail.file
						@mail.file = stg.store(MailPart.new({ :content_type => body.type, :content_length => body.io.length }, body.io))
						@mail.size = body.io.length
						@mail.excerpt = if body.type == 'text/plain'
							io = stg.load(@mail.file).data
							ret = nil
							begin
								ret = io.read(64)
							ensure
								io.close
							end
							
							ret
						else
							''
						end
						stg.drop(old) if old != nil and stg.exists?(old)
						@db.mails.update(@mail)
					end
				end
				
				class AttachmentsResource < Resource
					class AttachmentCreateModel < Model
						property! :name, String
					end
					
					class AttachmentResource < Resource
						def initialize(db, att)
							@db = db
							@att = att
						end
						
						def close(tail)
							@db.close if tail
						end
						
						action :delete, Types::Void, AuthorizeAttribute[] do
							raise(InvalidOperationException.new('Only drafts can be edited!')) unless @att.mail.state.moniker == DB::TypeStates::DRAFT
							stg = interconnect.fetch(MailStorage)
							
							stg.drop(@att.file) if @att.file != nil and stg.exists?(@att.file)
							@db.attachments.delete(@att)
						end
						
						action :fetch, MimeStream, AuthorizeAttribute[] do
							stg = interconnect.fetch(MailStorage)
							raise(NotFoundException.new('Attachment file not found!')) unless @att.file != nil and stg.exists?(@att.file)
							part = stg.load(@att.file)
							
							MimeStream.new(part[:content_type], BoundedIO.new(part.data, part[:content_length]))
						end
						
						action :update, Types::Void, AuthorizeAttribute[], :body! => MimeStream do |body|
							raise(InvalidOperationException.new('Only drafts can be edited!')) unless @att.mail.state.moniker == DB::TypeStates::DRAFT
							stg = interconnect.fetch(MailStorage)
							
							old = @att.file
							@att.file = stg.store(MailPart.new({ :content_type => body.type, :content_length => body.io.length }, body.io))
							@att.size = body.io.length
							stg.drop(old) if old != nil and stg.exists?(old)
							@db.attachments.update(@att)
						end
					end
					
					def initialize(db, mail)
						@db = db
						@mail = mail
					end
					
					def close(tail)
						@db.close if tail
					end
					
					action :create, IdModel, AuthorizeAttribute[],
						:body => AttachmentCreateModel do |body|
						att = @db.attachments << DB::Attachment.new(:name => body.name, :type => 'text/plain', :size => 0, :mail => @mail)
						
						IdModel.new(:id => att.id)
					end
					
					action :fetch, DataPage, AuthorizeAttribute[] do
						attachments = []
						@db.attachments.select { |i| i.mail == @mail }.each do |att|
							attachments << AttachmentModel.new(:id => att.id, :name => att.name, :type => att.type, :size => att.size)
						end
						
						DataPage.new(:items => attachments, :total => attachments.length)
					end
					
					action :select, AttachmentResource, AuthorizeAttribute[], DefaultAction[] do |id|
						raise(ArgumentException.new('id', 'Id must be positive integer!')) unless id =~ /^\d+$/
						id = id.to_i
						
						att = @db.attachments.find { |i| (i.mail == @mail).and(i.id == id) }
						raise(NotFoundException.new('Attachment not found!')) if att == nil
						
						AttachmentResource.new(@db, att)
					end
				end
				
				action :send, Types::Void, AuthorizeAttribute[] do
					raise(InvalidOperationException.new('Only drafts can be sent!')) unless @mail.state.moniker == DB::TypeStates::DRAFT
					
					@link.collection = @mail.mailbox.outbox
					@db.collection_mails.update(@link)
					@mail.state = @db.state_types.find { |i| i.moniker == DB::TypeStates::OUTBOUND }
					@db.mails.update(@mail)
					
					jobs = interconnect.fetch(JobServer)
					jobs.add_job_pool(:smtp) unless jobs.job_pool?(:smtp)
					jobs.add_job_to_pool(:smtp, SMTP::MailboxSendJob.new(interconnect.fetch(DbServer), interconnect.fetch(MailStorage), @mail.mailbox.id, @mail.mailbox.address))
				end
				
				action :fetch, MailModel, AuthorizeAttribute[] do
					attachments = []
					@db.attachments.select { |i| i.mail == @mail }.each do |att|
						attachments << AttachmentModel.new(:id => att.id, :name => att.name, :type => att.type, :size => att.size)
					end
					
					recp = []
					@db.mail_participants.select { |i| i.mail == @mail }.each do |join|
						recp << ParticipantModel.from_db(@db, join.participant)
					end
					
					MailModel.new(
						:subject => @mail.subject,
						:excerpt => @mail.excerpt,
						:date => @mail.date_time.to_s,
						:sender => ParticipantModel.from_db(@db, @mail.sender),
						:state => @mail.state.moniker,
						:read => @mail.read?,
						:size => @mail.size,
						:attachments => attachments,
						:recipients => recp
					)
				end
				
				action :body, BodyResource, AuthorizeAttribute[] do
					BodyResource.new(@db, @mail)
				end
				
				action :delete, Types::Void, AuthorizeAttribute[] do
					@mail.references -= 1
					@db.mails.update(@mail)
					@db.collection_mails.delete(@link)
				end
				
				action :attachments, AttachmentsResource, AuthorizeAttribute[] do
				  AttachmentsResource.new(@db, @mail)
				end
			end
			
			action :fetch, DataPage, AuthorizeAttribute[],
				:page => { :type => Integer, :default => 0 },
				:limit => { :type => Integer, :default => 0 } do |page, limit|
				raise(ArgumentException.new('page', 'Must be positive!')) if page < 0
				raise(ArgumentException.new('limit', 'Must be positive!')) if limit < 0
				
				ret = []
				total = nil
				
				enum = @db.collection_mails.select { |i| i.collection == @col }
				total = enum.count
				enum = enum.drop(page * limit).take(limit) if limit > 0
				
				enum.each do |join|
					ret << MailShortModel.new(
						:id => join.mail.id,
						:subject => join.mail.subject,
						:date => join.mail.date_time.to_s,
						:sender => join.mail.sender.tag,
						:state => join.mail.state.moniker,
						:read => join.mail.read?,
						:attachments => @db.attachments.count { |i| i.mail == join.mail }
					)
				end
				
				DataPage.new(:items => ret, :total => total)
			end
			
			action :select, MailResource, AuthorizeAttribute[], DefaultAction[] do |id|
				raise(ArgumentException.new('id', 'Id must be positive integer!')) unless id =~ /^\d+$/
				id = id.to_i
				db = interconnect.fetch(DbServer).open(DB::RomDbContext)
				link = db.protect { db.collection_mails.find { |i| (i.collection == @col).and(i.mail == id) } }
				raise(NotFoundException.new('Mail not found in this collection!')) if link == nil
				
				MailResource.new(db, link)
			end
		end
	end
end