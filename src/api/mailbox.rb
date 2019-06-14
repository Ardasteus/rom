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
				
				def self.from_db(mod)
					self.new(:host => mod.host, :port => mod.port, :user => mod.user, :password => mod.password, :protection => mod.protection&.moniker)
				end
			end
			
			class MapModel < Model
				property! :path, String
				property! :filter, String
			end
			
			class MailboxCreateModel < Model
				property! :name, String
				property! :address, String
				property! :author, String
				property! :maps, Types::Array[MapModel]
				property :imap, ConnectionModel
				property :smtp, ConnectionModel
			end
			
			class MailboxResource < Resource
				class PersonModel < Model
					property! :id, Integer # TODO: User + Contact ID
					property! :name, String
				end
				
				class MailboxModel < Model
					property! :name, String
					property! :address, String
					property! :author, String
					property! :writable, Types::Boolean[]
					property! :owner, PersonModel
					property! :maps, Types::Array[MapModel]
					property :imap, ConnectionModel
					property :smtp, ConnectionModel
				end
				
				class ShareModel < Model
					property! :user, PersonModel
					property! :can_write, Types::Boolean[]
				end
				
				def initialize(db, user, box)
					@db = db
					@user = user
					@box = box
				end
				
				def close(tail)
					@db.close if tail
				end
				
				action :fetch, MailboxModel, AuthorizeAttribute[] do
					writable = @box.owner == @user
					unless writable
						share = @db.mailbox_users.find { |i| (i.mailbox == @box).and(i.user == @user) }
						writable = (share.can_write == 1) if share != nil
					end
					contact = @box.owner.contact
					owner = PersonModel.new(:id => contact.id, :name => contact.full_name)
					maps = []
					@db.maps.select { |i| i.mailbox == @box }.each do |m|
						maps << MapModel.new(:path => m.collection.full_path, :filter => m.filter)
					end
					
					MailboxModel.new(
						:name => @box.name,
						:address => @box.address,
						:author => @box.author,
						:writable => writable,
						:owner => owner,
						:maps => maps,
						:imap => (@box.imap != nil ? ConnectionModel.from_db(@box.imap) : nil),
						:smtp => (@box.smtp != nil ? ConnectionModel.from_db(@box.smtp) : nil)
					)
				end
				
				action :shares, DataPage, AuthorizeAttribute[] do
					raise(UnauthorizedException.new) unless @box.owner == @user
					ret = []
					@db.mailbox_users.select { |i| i.mailbox == @box }.each do |share|
						contact = share.user.contact
						ret << ShareModel.new(:user => PersonModel.new(:id => contact.id, :name => contact.full_name), :can_write => share.can_write == 1)
					end
					
					DataPage.new(:items => ret, :total => ret.length)
				end
			end
			
			action :create, Types::Void, AuthorizeAttribute[],
				:body! => MailboxCreateModel do |body|
				raise(ArgumentException.new('body', 'Invalid address!')) unless body.address =~ ContactsResource::RGX_ADDRESS
				rgx = MailsController::CollectionResource::RGX_PATH
				body.maps.each do |i|
					raise(ArgumentException.new('path', 'Invalid path format!')) unless i.path =~ rgx
					raise(ArgumentException.new('filter', 'Invalid path format!')) unless i.filter =~ rgx
					raise(ArgumentException.new('filter', 'Filter cannot be rooted!')) if i.filter == '/'
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
					
					box = DB::Mailbox.new(:name => body.name, :author => body.author, :address => body.address, :owner => user)
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
					ctx.mailbox_users.select { |i| i.user == user }.each do |share|
						box = share.mailbox
						ret << MailboxSmallModel.new(:id => box.id, :name => box.name, :address => box.address, :own => false, :writable => share.can_write == 1)
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
					box = db.mailbox_users.find { |i| (i.mailbox == id).and(i.user == user) }&.mailbox if box == nil
					raise(NotFoundException.new('Mailbox not found!')) if box == nil
				end
				
				MailboxResource.new(db, user, box)
			end
		end
	end
end