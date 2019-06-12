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
				class AddressModel < Model
					property! :name, String
					property! :address, String
					property! :type, String
				end
				
				class ContactDetailModel < Model
					property! :first_name, String
					property :last_name, String
					property! :addresses, Types::Array[AddressModel]
				end
				
				def initialize(db, con)
					@db = db
					@con = con
				end
				
				action :fetch, ContactDetailModel, AuthorizeAttribute[] do
					ret = []
					@db.contact_addresses.select { |i| i.contact == @con }.each do |adr|
						ret << AddressModel.new(:name => adr.name, :address => adr.address, :type => adr.type.moniker.downcase)
					end
					
					ContactDetailModel.new(:first_name => @con.first_name, :last_name => @con.last_name, :addresses => ret)
				end
				
				def close(tail)
					@db.close
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