# Created by Matyáš Pokorný on 2019-06-12.

module ROM
	module API
		class ContactsResource < StaticResource
			namespace :api, :v1, :contacts
			
			class ContactModel < Model
				property! :id, Integer
				property! :first_name, String
				property :last_name, String
			end
			
			class ContactResource < Resource
				class AddressRequestModel < Model
					property :name, String
					property :address, String
					property :type, String
				end
				
				class AddressModel < Model
					property! :id, Integer
					property! :name, String
					property! :address, String
					property! :type, String
				end
				
				class ContactDetailModel < Model
					property! :first_name, String
					property :last_name, String
					property! :addresses, Types::Array[AddressModel]
				end
				
				class ContactUpdateModel < Model
					property :first_name, String
					property :last_name, String
				end
				
				def initialize(db, con, edit = false)
					@db = db
					@con = con
					@edit = edit
				end
				
				class AddressesResource < Resource
					def initialize(db, con)
						@db = db
						@con = con
					end
					
					class AddressResource < Resource
						def initialize(db, adr)
							@db = db
							@adr = adr
						end
						
						action :fetch, AddressModel, AuthorizeAttribute[] do
							AddressModel.new(:id => @adr.id, :name => @adr.name, :address => @adr.address, :type => @adr.type.moniker)
						end
						
						action :update, Types::Void, AuthorizeAttribute[],
							:body => AddressRequestModel do |body|
							if body.address != nil
								raise(ArgumentException.new('address', 'Address is in invalid format!')) unless body.address =~ ApiConstants::RGX_ADDRESS
								@adr.address = body.address
							end
							if body.type != nil
								type = @db.address_types.find { |i| i.moniker == body.type.downcase }
								raise(ArgumentException.new('type', 'Address type not found!')) if type == nil
								@adr.type = type
							end
							if body.name != nil
								name = body.name.downcase.strip
								raise(ArgumentException.new('name', 'Name collision!')) if @db.contact_addresses.any? { |i| (i.contact == @con).and(i.name.downcase == name) }
								@adr.name = name
							end
							
							@db.contact_addresses.update(@adr)
						end
						
						action :delete, Types::Void, AuthorizeAttribute[] do
						  @db.contact_addresses.delete(@adr)
						end
						
						def close(tail)
							@db.close if tail
						end
					end
					
					action :create, Types::Void, AuthorizeAttribute[],
						:body! => AddressRequestModel do |body|
						raise(ArgumentException.new('address', 'Is nil!')) if body.address == nil
						raise(ArgumentException.new('type', 'Is nil!')) if body.type == nil
						raise(ArgumentException.new('name', 'Is nil!')) if body.name == nil
						
						raise(ArgumentException.new('address', 'Address is in invalid format!')) unless body.address =~ ApiConstants::RGX_ADDRESS
						type = @db.address_types.find { |i| i.moniker == body.type.downcase }
						raise(ArgumentException.new('type', 'Address type not found!')) if type == nil
						name = body.name.downcase.strip
						raise(ArgumentException.new('name', 'Name collision!')) if @db.contact_addresses.any? { |i| (i.contact == @con).and(i.name.downcase == name) }
						
						@db.contact_addresses << DB::ContactAddress.new(:name => body.name, :address => body.address, :type => type, :contact => @con)
					end
					
					action :fetch, DataPage, AuthorizeAttribute[],
						:query => String,
						:page => { :type => Integer, :default => 0 },
						:limit => { :type => Integer, :default => 0 } do |query, page, limit|
						raise(ArgumentException.new('page', 'Page must be non-negative number!')) if page < 0
						raise(ArgumentException.new('limit', 'Limit must be non-negative number!')) if limit < 0
						
						ret = []
						enum = @db.contact_addresses.select { |i| i.contact == @con }
						enum = enum.select { |i| i.name.include?(query).or(i.address.include?(query)) } unless query == nil
						count = enum.count
						enum = enum.drop(page * limit).take(limit) if limit > 0
						enum.each do |con|
							ret << AddressModel.new(:id => con.id, :name => con.name, :address => con.address, :type => con.type.moniker.downcase)
						end
						
						DataPage.new(:items => ret, :total => count)
					end
					
					action :address, AddressResource, AuthorizeAttribute[], DefaultAction[] do |id|
						raise(ArgumentException.new('id', 'Id must be positive integer!')) unless id =~ /^\d+$/
						id = id.to_i
						adr = @db.contact_addresses.find { |i| (i.contact == @con).and(i.id == id) }
						raise(NotFoundException.new('Address not found!')) if adr == nil
						
						AddressResource.new(@db, adr)
					end
					
					def close(tail)
						@db.close if tail
					end
				end
				
				action :addresses, AddressesResource do
					raise(UnauthorizedException.new) unless @edit
					
					AddressesResource.new(@db, @con)
				end
				
				action :fetch, ContactDetailModel, AuthorizeAttribute[] do
					ret = []
					@db.contact_addresses.select { |i| i.contact == @con }.each do |adr|
						ret << AddressModel.new(:id => adr.id, :name => adr.name, :address => adr.address, :type => adr.type.moniker.downcase)
					end
					
					ContactDetailModel.new(:first_name => @con.first_name, :last_name => @con.last_name, :addresses => ret)
				end
				
				action :update, Types::Void, AuthorizeAttribute[], :body! => ContactUpdateModel do |body|
					raise(UnauthorizedException.new) unless @edit
					
					@con.first_name = body.first_name unless body.first_name == nil
					@con.last_name = body.last_name unless body.last_name == nil
					@db.contacts.update(@con)
				end
				
				def close(tail)
					@db.close if tail
				end
			end
			
			action :fetch, DataPage, AuthorizeAttribute[],
				:query => String,
				:page => { :type => Integer, :default => 0 },
				:limit => { :type => Integer, :default => 0 } do |query, page, limit|
				raise(ArgumentException.new('page', 'Page must be non-negative number!')) if page < 0
				raise(ArgumentException.new('limit', 'Limit must be non-negative number!')) if limit < 0
				
				ret = []
				count = nil
				interconnect.fetch(DbServer).open(DB::RomDbContext) do |ctx|
					enum = ctx.contacts.select { |i| i.references > 0 }
					enum = enum.select { |i| i.first_name.include?(query).or(i.last_name.include?(query)) } unless query == nil
					count = enum.count
					enum = enum.drop(page * limit).take(limit) if limit > 0
					enum.each do |con|
						ret << ContactModel.new(:id => con.id, :first_name => con.first_name, :last_name => con.last_name)
					end
				end
				
				DataPage.new(:items => ret, :total => count)
			end
			
			action :contact, ContactResource, AuthorizeAttribute[], DefaultAction[] do |id|
				raise(ArgumentException.new('id', 'Id must be positive integer!')) unless id =~ /^\d+$/
				id = id.to_i
				db = interconnect.fetch(DbServer).open(DB::RomDbContext)
				con = db.protect { db.contacts.find(id) }
				raise(NotFoundException.new('Contact not found!')) if con == nil
				
				ContactResource.new(db, con)
			end
		end
	end
end