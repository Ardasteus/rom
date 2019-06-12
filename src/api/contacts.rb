# Created by Matyáš Pokorný on 2019-06-12.

module ROM
	module API
		class ContactsResource < StaticResource
			namespace :api, :v1, :contacts
			
			class ContactModel < Model
				property! :first_name, String
				property :last_name, String
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
						ret << ContactModel.new(:first_name => con.first_name, :last_name => con.last_name)
					end
				end
				
				DataPage.new(:items => ret, :total => count)
			end
		end
	end
end