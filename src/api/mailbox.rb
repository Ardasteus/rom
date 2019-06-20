# Created by Matyáš Pokorný on 2019-06-14.

module ROM
	module API
		class MailboxesResource < StaticResource
			namespace :api, :v1, :mailboxes
			
			class MailboxSmallModel < Model
				property! :id, Integer
				property! :name, String
				property! :address, String
				property! :writable, Types::Boolean[]
				property! :own, Types::Boolean[]
			end
			
			class ConnectionModel < Model
				property! :host, String
				property! :port, Integer
				property! :user, String
				property :password, String
				property :protection, String
				
				def to_db(db)
					ret = DB::Connection.new(:host => host, :port => port, :user => user, :password => password)
					
					if protection != nil
						ptc = db.protection_types.find { |i| i.moniker.downcase == protection.downcase }
						raise(ArgumentException.new('protection', 'Protection type not found!')) if ptc == nil
						
						ret.protection = ptc
					end
					
					ret
				end
				
				def to_entity(db, e)
					e.host = host
					e.port = port
					e.user = user
					e.password = password
					
					if protection != nil
						ptc = db.protection_types.find { |i| i.moniker.downcase == protection.downcase }
						raise(ArgumentException.new('protection', 'Protection type not found!')) if ptc == nil
						
						e.protection = ptc
					end
					
					e
				end
				
				def self.from_db(mod)
					self.new(:host => mod.host, :port => mod.port, :user => mod.user, :protection => mod.protection&.moniker)
				end
			end
			
			class MapSimpleModel < Model
				property! :path, String
				property! :filter, String
			end
			
			class MailboxCreateModel < Model
				property! :name, String
				property! :address, String
				property :author, String
				property! :maps, Types::Array[MapSimpleModel]
				property! :drafts, String
				property! :outbox, String
				property :imap, ConnectionModel
				property :smtp, ConnectionModel
			end
			
			class MailboxResource < Resource
				class PersonModel < Model
					property! :user, Integer
					property! :contact, Integer
					property! :name, String
				end
				
				class MailboxModel < Model
					property! :name, String
					property! :address, String
					property! :author, String
					property! :writable, Types::Boolean[]
					property! :owner, PersonModel
					property! :drafts, String
					property! :outbox, String
					property :imap, ConnectionModel
					property :smtp, ConnectionModel
				end
				
				class MailboxUpdateModel < Model
					property :name, String
					property :address, String
					property :author, String
					property :drafts, String
					property :outbox, String
					property :imap, ConnectionModel
					property :smtp, ConnectionModel
				end
				
				class MailCreateModel < Model
					property! :subject, String
					property! :recipients, Types::Array[String]
				end
				
				class MapsResource < Resource
					class MapModel < Model
						property :id, Integer
						property! :path, String
						property! :filter, String
					end
					
					def initialize(db, box)
						@db = db
						@box = box
					end
					
					def close(tail)
						@db.close if tail
					end
					
					class MapResource < Resource
						def initialize(db, map)
							@db = db
							@map = map
						end
						
						def close(tail)
							@db.close if tail
						end
						
						action :fetch, MapModel, AuthorizeAttribute[] do
							MapModel.new(:id => @map.id, :path => @map.collection.full_path, :filter => @map.filter)
						end
						
						action :delete, Types::Void, AuthorizeAttribute[] do
							@db.maps.delete(@map)
						end
					end
					
					action :fetch, DataPage, AuthorizeAttribute[] do
						ret = []
						@db.maps.select { |i| i.mailbox == @box }.each do |map|
							ret << MapModel.new(:id => map.id, :path => map.collection.full_path, :filter => map.filter)
						end
						
						DataPage.new(:items => ret, :total => ret.length)
					end
					
					action :create, Types::Void, AuthorizeAttribute[],
						:body! => MapModel do |body|
						raise(ArgumentException.new('filter', 'Invalid path format!')) unless body.filter =~ ApiConstants::RGX_PATH
						raise(ArgumentException.new('filter', 'Filter cannot be root!')) if body.filter == '/'
						
						col = @db.users.find(identity.id).collection.find(@db, body.path[1..body.path.length - 1])
						raise(NotFoundException.new('Collection not found!')) if col == nil
						
						@db.maps << DB::Map.new(:mailbox => @box, :collection => col, :filter => body.filter)
					end
					
					action :select, MapResource, AuthorizeAttribute[], DefaultAction[] do |id|
						raise(ArgumentException.new('id', 'Id must be positive integer!')) unless id =~ /^\d+$/
						id = id.to_i
						map = @db.maps.find(id)
						raise(NotFoundException.new('Map not found!')) if map == nil
						
						MapResource.new(@db, map)
					end
				end
				
				class ConnectionResource < Resource
					def initialize(db, con, &box_set)
						@db = db
						@box_set = box_set
						@con = con
					end
					
					def close(tail)
						@db.close if tail
					end
					
					action :update, Types::Void, AuthorizeAttribute[],
						:body! => ConnectionModel do |body|
						body.to_entity(@db, @con)
						@db.connections.update(@con)
					end
					
					action :delete, Types::Void, AuthorizeAttribute[] do
						raise(NotFoundException.new('Connection not found!')) if @con == nil
						
						@box_set.call(nil)
						@db.connections.delete(@con)
					end
					
					action :create, Types::Void, AuthorizeAttribute[],
						:body! => ConnectionModel do |body|
						raise(InvalidOperationException.new('Connection already defined!')) unless @con == nil
						
						@box_set.call(@db.connections << body.to_db(@db))
					end
					
					action :fetch, ConnectionModel, AuthorizeAttribute[] do
						raise(NotFoundException.new('Connection not found!')) if @con == nil
						
						ConnectionModel.from_db(@con)
					end
				end
				
				def initialize(db, user, box)
					@db = db
					@user = user
					@box = box
				end
				
				def close(tail)
					@db.close if tail
				end
				
				action :create, IdModel, AuthorizeAttribute[],
					:body! => MailCreateModel do |body|
					raise(ArgumentException.new('subject', 'Subject is empty!')) if body.subject.strip.length == 0
					raise(ArgumentException.new('recipients', 'No recipient given!')) if body.recipients.length == 0
					
					recipients = []
					body.recipients.each do |r|
						raise(ArgumentException.new('recipients', 'Same recipient specified multiple times!')) if recipients.any? { |i| i.address == r }
						
						addr = @db.contact_addresses.find { |i| i.address == r }
						recipients << if addr == nil
							DB::Participant.new(:address => r)
						else
							par = @db.participants.find { |i| i.contact == addr.contact }
							
							par == nil ? DB::Participant.new(:name => addr.contact.full_name, :address => r, :contact => addr.contact) : par
						end
					end
					
					me = @db.users.find(identity.id).contact
					owner = @db.participants.find { |i| (i.contact == me).and(i.address == @box.address) }
					owner = @db.participants << DB::Participant.new(:name => @box.author, :address => @box.address, :contact => me, :references => 0) if owner == nil
					
					idx = recipients.index { |i| i.address == @box.address }
					recipients[idx] = owner if idx != nil
					
					mail = @db.mails << DB::Mail.new(
						:subject => body.subject,
						:date => Time.now.to_i,
						:excerpt => '',
						:sender => owner,
						:state => @db.mail_state_types.find { |i| i.moniker == DB::TypeMailState::DRAFT },
						:reply_address => @box.address,
						:mailbox => @box,
						:is_local => 1,
						:is_read => 1
					)
					
					owner.references += 1
					@db.participants.update(owner)
					
					recipients.collect! do |r|
						if r.is_a?(Entity)
							r.references += 1
							@db.participants.update(r)
							
							r
						else
							@db.participants << r
						end
					end
					
					recipients.each do |r|
						@db.mail_participants << DB::MailParticipant.new(:mail => mail, :participant => r)
					end
					
					@db.collection_mails << DB::CollectionMail.new(:collection => @box.drafts, :mail => mail)
					
					IdModel.new(:id => mail.id)
				end
				
				action :fetch, MailboxModel, AuthorizeAttribute[] do
					owner = PersonModel.new(:user => @box.owner.id, :contact => @box.owner.contact.id, :name => @box.owner.contact.full_name)
					
					MailboxModel.new(
						:name => @box.name,
						:address => @box.address,
						:author => @box.author,
						:writable => true,
						:owner => owner,
						:drafts => @box.drafts.full_path,
						:outbox => @box.outbox.full_path,
						:imap => (@box.imap != nil ? ConnectionModel.from_db(@box.imap) : nil),
						:smtp => (@box.smtp != nil ? ConnectionModel.from_db(@box.smtp) : nil)
					)
				end
				
				action :update, Types::Void, AuthorizeAttribute[],
					:body! => MailboxUpdateModel do |body|
					
					if body.address != nil
						raise(ArgumentException.new('body', 'Invalid address!')) unless body.address =~ ApiConstants::RGX_ADDRESS
						@box.address = body.address
					end
					@box.name = body.name unless body.name == nil
					@box.author = body.author unless body.author == nil
					@box.imap = (@box.imap == nil ? body.imap.to_db(@db) : body.imap.to_entity(@db, @box.imap)) if body.imap != nil
					@box.smtp = (@box.smtp == nil ? body.smtp.to_db(@db) : body.smtp.to_entity(@db, @box.smtp)) if body.smtp != nil
					if body.drafts != nil
						raise(ArgumentException.new('drafts', 'Invalid path!')) unless body.drafts =~ ApiConstants::RGX_PATH
						col = @user.collection.find(@db, body.drafts[1..body.drafts.length - 1])
						raise(NotFoundException.new('Draft collection not found!')) if col == nil
						@box.drafts = col
					end
					if body.outbox != nil
						raise(ArgumentException.new('outbox', 'Invalid path!')) unless body.outbox =~ ApiConstants::RGX_PATH
						col = @user.collection.find(@db, body.outbox[1..body.outbox.length - 1])
						raise(NotFoundException.new('Outbox collection not found!')) if col == nil
						@box.outbox = col
					end
					
					@db.mailboxes.update(@box)
				end
				
				action :maps, MapsResource, AuthorizeAttribute[] do
					raise(UnauthorizedException.new) unless @box.owner == @user
					
					MapsResource.new(@db, @box)
				end
				
				action :imap, ConnectionResource, AuthorizeAttribute[] do
					box = @box
					db = @db
					ConnectionResource.new(@db, @box.imap) { |imap| box.imap = imap; db.mailboxes.update(box) }
				end
				
				action :smtp, ConnectionResource, AuthorizeAttribute[] do
					box = @box
					db = @db
					ConnectionResource.new(@db, @box.smtp) { |smtp| box.smtp = smtp; db.mailboxes.update(box) }
				end
				
				action :sync, Types::Void, AuthorizeAttribute[] do
					jobs = interconnect.fetch(JobServer)
					jobs.add_job_pool(:smtp) unless jobs.job_pool?(:smtp)
					jobs.add_job_to_pool(:smtp, SMTP::MailboxSendJob.new(interconnect.fetch(DbServer), interconnect.fetch(MailStorage), @box.id, @box.address))
				end
			end
			
			action :create, Types::Void, AuthorizeAttribute[],
				:body! => MailboxCreateModel do |body|
				raise(ArgumentException.new('body', 'Invalid address!')) unless body.address =~ ApiConstants::RGX_ADDRESS
				raise(ArgumentException.new('drafts', 'Invalid path!')) unless body.drafts =~ ApiConstants::RGX_PATH
				raise(ArgumentException.new('outbox', 'Invalid path!')) unless body.outbox =~ ApiConstants::RGX_PATH
				body.maps.each do |i|
					raise(ArgumentException.new('path', 'Invalid path format!')) unless i.path =~ ApiConstants::RGX_PATH
					raise(ArgumentException.new('filter', 'Invalid path format!')) unless i.filter =~ ApiConstants::RGX_PATH
					raise(ArgumentException.new('filter', 'Filter cannot be root!')) if i.filter == '/'
				end
				interconnect.fetch(DbServer).open(DB::RomDbContext) do |ctx|
					raise(InvalidOperationException.new('Address already used!')) if ctx.mailboxes.any? { |i| i.address == body.address }
					user = ctx.users.find(identity.id)
					
					maps = []
					body.maps.each do |m|
						col = user.collection.find(ctx, m.path[1..m.path.length - 1])
						raise(NotFoundException.new("Collection not found!: #{m.path}")) if col == nil
						maps << { :collection => col, :filter => m.filter }
					end
					
					drafts = user.collection.find(ctx, body.drafts[1..body.drafts.length - 1])
					raise(NotFoundException.new('Drafts collection not found!')) if drafts == nil
					outbox = user.collection.find(ctx, body.outbox[1..body.outbox.length - 1])
					raise(NotFoundException.new('Outbox collection not found!')) if outbox == nil
					
					box = DB::Mailbox.new(:name => body.name, :author => (body.author or user.contact.full_name), :address => body.address, :owner => user, :outbox => outbox, :drafts => drafts)
					box.imap = body.imap.to_db(ctx) if body.imap != nil
					box.smtp = body.smtp.to_db(ctx) if body.smtp != nil
					
					box = ctx.mailboxes << box
					maps.each { |m| ctx.maps << DB::Map.new(:mailbox => box, **m) }
				end
			end
			
			action :fetch, DataPage, AuthorizeAttribute[] do
				ret = []
				interconnect.fetch(DbServer).open(DB::RomDbContext) do |ctx|
					user = ctx.users.find(identity.id)
					ctx.mailboxes.select { |i| i.owner == user }.each do |box|
						ret << MailboxSmallModel.new(:id => box.id, :name => box.name, :address => box.address, :own => true, :writable => true)
					end
				end
				
				DataPage.new(:items => ret, :total => ret.length)
			end
			
			action :select, MailboxResource, AuthorizeAttribute[], DefaultAction[] do |id|
				raise(ArgumentException.new('id', 'Id must be positive integer!')) unless id =~ /^\d+$/
				id = id.to_i
				db = interconnect.fetch(DbServer).open(DB::RomDbContext)
				user = nil
				box = nil
				db.protect do
					user = db.users.find(identity.id)
					box = db.mailboxes.find { |i| (i.id == id).and(i.owner == user) }
					raise(NotFoundException.new('Mailbox not found!')) if box == nil
				end
				
				MailboxResource.new(db, user, box)
			end
		end
	end
end