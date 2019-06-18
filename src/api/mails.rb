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
				
				class MailModel < Model
					property! :subject, String
					property! :date, String
					property! :sender, String
					property! :state, String
					property! :excerpt, String
					property! :read, Types::Boolean[]
					property! :attachments, Types::Array[AttachmentModel]
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
					def initialize(db, stg, mail)
						@db = db
						@stg = stg
						@mail = mail
					end
					
					def close(tail)
						@db.close if tail
					end
					
					action :fetch, MimeStream, AuthorizeAttribute[] do
						raise(NotFoundException.new('Mail file not found!')) unless @stg.exists?(@mail.file)
						part = @stg.load(@mail.file)
						
						MimeStream.new(part[:content_type], BoundedIO.new(part.data, part[:content_length]))
					end
					
					action :update, Types::Void, AuthorizeAttribute[], :body! => MimeStream do |body|
						old = @mail.file
						@mail.file = @stg.store(MailPart.new({ :content_type => body.type, :content_length => body.io.length }, body.io))
						@stg.drop(old) if @stg.exists?(old)
						@db.mails.update(@mail)
					end
				end
				
				action :fetch, MailModel, AuthorizeAttribute[] do
					attachments = []
					@db.attachments.select { |i| i.mail == @mail }.each do |att|
						attachments << AttachmentModel.new(:id => att.id, :name => att.name, :type => att.type, :size => att.size)
					end
					
					MailModel.new(
						:subject => @mail.subject,
						:excerpt => @mail.excerpt,
						:date => @mail.date_time.to_s,
						:sender => @mail.sender.tag,
						:state => @mail.state.moniker,
						:read => @mail.read?,
						:attachments => attachments
					)
				end
				
				action :body, BodyResource, AuthorizeAttribute[] do
					BodyResource.new(@db, interconnect.fetch(MailStorage), @mail)
				end
				
				action :delete, Types::Void, AuthorizeAttribute[] do
					@mail.references -= 1
					@db.mails.update(@mail)
					@db.collection_mails.delete(@link)
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