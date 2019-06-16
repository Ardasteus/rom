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
					self.new(:host => mod.host, :port => mod.port, :user => mod.user, :password => mod.password, :protection => mod.protection&.moniker)
				end
			end
			
			class MapSimpleModel < Model
				property! :path, String
				property! :filter, String
			end
			
			class MailboxCreateModel < Model
				property! :name, String
				property! :address, String
				property! :author, String
				property! :maps, Types::Array[MapSimpleModel]
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
					property :imap, ConnectionModel
					property :smtp, ConnectionModel
				end
				
				class MailboxUpdateModel < Model
					property :name, String
					property :address, String
					property :author, String
					property :imap, ConnectionModel
					property :smtp, ConnectionModel
				end
				
				# class SharesResource < Resource
				# 	class ShareModel < Model
				# 		property! :user, PersonModel
				# 		property! :can_write, Types::Boolean[]
				# 	end
				#
				# 	class ShareCreateModel < Model
				# 		property! :user, Integer
				# 		property :can_write, Types::Boolean[], false
				# 	end
				#
				# 	def initialize(db, box)
				# 		@db = db
				# 		@box = box
				# 	end
				#
				# 	def close(tail)
				# 		@db.close if tail
				# 	end
				#
				# 	class ShareResource < Resource
				# 		class ShareUpdateModel < Model
				# 			property! :can_write, Types::Boolean[]
				# 		end
				#
				# 		def initialize(db, share)
				# 			@db = db
				# 			@share = share
				# 		end
				#
				# 		def close(tail)
				# 			@db.close if tail
				# 		end
				#
				# 		action :delete, Types::Void, AuthorizeAttribute[] do
				# 			@db.mailbox_users.delete(@share)
				# 		end
				#
				# 		action :update, Types::Void, AuthorizeAttribute[],
				# 		:body! => ShareUpdateModel do |body|
				# 			@share.can_write = (body.can_write ? 1 : 0)
				# 			@db.mailbox_users.update(@share)
				# 		end
				# 	end
				#
				# 	action :create, Types::Void, AuthorizeAttribute[],
				# 		:body! => ShareCreateModel do |body|
				# 		user = @db.users.find(body.user)
				# 		raise(NotFoundException.new('User not found!')) if user == nil
				# 		raise(InvalidOperationException.new('User already set!')) if @db.mailbox_users.any? { |i| (i.mailbox == @box).and(i.user == user) }
				#
				# 		@db.mailbox_users << DB::MailboxUser.new(:mailbox => @box, :user => user, :can_write => (body.can_write ? 1 : 0))
				# 	end
				#
				# 	action :fetch, DataPage, AuthorizeAttribute[] do
				# 		ret = []
				# 		@db.mailbox_users.select { |i| i.mailbox == @box }.each do |share|
				# 			contact = share.user.contact
				# 			ret << ShareModel.new(:user => PersonModel.new(:user => share.user.id, :contact => contact.id, :name => contact.full_name), :can_write => share.can_write == 1)
				# 		end
				#
				# 		DataPage.new(:items => ret, :total => ret.length)
				# 	end
				#
				# 	action :select, ShareResource, AuthorizeAttribute[], DefaultAction[] do |id|
				# 		raise(ArgumentException.new('id', 'Id must be positive integer!')) unless id =~ /^\d+$/
				# 		id = id.to_i
				# 		user = @db.users.find(id)
				# 		raise(NotFoundException.new('User not found!')) if user == nil
				# 		share = @db.mailbox_users.find(:mailbox => @box, :user => user)
				# 		raise(NotFoundException.new('Share not found!')) if share == nil
				#
				# 		ShareResource.new(@db, share)
				# 	end
				# end
				
				class MapsResource < Resource
					class MapModel < Model
						property :id, Integer
						property! :collection, String
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
							MapModel.new(:id => @map.id, :collection => @map.collection.full_path, :filter => @map.filter)
						end
						
						action :delete, Types::Void, AuthorizeAttribute[] do
							@db.maps.delete(@map)
						end
					end
					
					action :fetch, DataPage, AuthorizeAttribute[] do
						ret = []
						@db.maps.select { |i| i.mailbox == @box }.each do |map|
							ret << MapModel.new(:id => map.id, :collection => map.collection.full_path, :filter => map.filter)
						end
						
						DataPage.new(:items => ret, :total => ret.length)
					end
					
					action :create, Types::Void, AuthorizeAttribute[],
						:body! => MapModel do |body|
						raise(ArgumentException.new('filter', 'Invalid path format!')) unless body.filter =~ MailsController::CollectionResource::RGX_PATH
						raise(ArgumentException.new('filter', 'Filter cannot be root!')) if body.filter == '/'
						
						col = @db.users.find(identity.id).collection.find(@db, body.collection[1..body.collection.length - 1])
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
						
						ConnectionModel.new(:host => @con.host, :port => @con.port, :user => @con.user, :password => @con.password, :protection => @con.protection&.moniker)
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
				
				action :fetch, MailboxModel, AuthorizeAttribute[] do
					# writable = @box.owner == @user
					# unless writable
					# 	share = @db.mailbox_users.find { |i| (i.mailbox == @box).and(i.user == @user) }
					# 	writable = (share.can_write == 1) if share != nil
					# end
					owner = PersonModel.new(:user => @box.owner.id, :contact => @box.owner.contact.id, :name => @box.owner.contact.full_name)
					
					MailboxModel.new(
						:name => @box.name,
						:address => @box.address,
						:author => @box.author,
						:writable => true,
						:owner => owner,
						:imap => (@box.imap != nil ? ConnectionModel.from_db(@box.imap) : nil),
						:smtp => (@box.smtp != nil ? ConnectionModel.from_db(@box.smtp) : nil)
					)
				end
				
				action :update, Types::Void, AuthorizeAttribute[],
					:body! => MailboxUpdateModel do |body|
					
					if body.address != nil
						raise(ArgumentException.new('body', 'Invalid address!')) unless body.address =~ ContactsResource::RGX_ADDRESS
						@box.address = body.address
					end
					@box.name = body.name unless body.name == nil
					@box.author = body.author unless body.author == nil
					@box.imap = (@box.imap == nil ? body.imap.to_db(@db) : body.imap.to_entity(@db, @box.imap)) if body.imap != nil
					@box.smtp = (@box.smtp == nil ? body.smtp.to_db(@db) : body.smtp.to_entity(@db, @box.smtp)) if body.smtp != nil
					
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
				
				# action :shares, SharesResource, AuthorizeAttribute[] do
				# 	raise(UnauthorizedException.new) unless @box.owner == @user
				#
				# 	SharesResource.new(@db, @box)
				# end
			end
			
			action :create, Types::Void, AuthorizeAttribute[],
				:body! => MailboxCreateModel do |body|
				raise(ArgumentException.new('body', 'Invalid address!')) unless body.address =~ ContactsResource::RGX_ADDRESS
				rgx = MailsController::CollectionResource::RGX_PATH
				body.maps.each do |i|
					raise(ArgumentException.new('path', 'Invalid path format!')) unless i.path =~ rgx
					raise(ArgumentException.new('filter', 'Invalid path format!')) unless i.filter =~ rgx
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
					# ctx.mailbox_users.select { |i| i.user == user }.each do |share|
					# 	box = share.mailbox
					# 	ret << MailboxSmallModel.new(:id => box.id, :name => box.name, :address => box.address, :own => false, :writable => share.can_write == 1)
					# end
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
					# box = db.mailbox_users.find { |i| (i.mailbox == id).and(i.user == user) }&.mailbox if box == nil
					raise(NotFoundException.new('Mailbox not found!')) if box == nil
				end
				
				MailboxResource.new(db, user, box)
			end
		end
	end
end