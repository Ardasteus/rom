# Created by Matyáš Pokorný on 2019-06-10.

module ROM
	module API
		class UsersController < StaticResource
			namespace :api, :v1, :users
			
			class UserModel < Model
				property! :login, String
				property! :first_name, String
				property :last_name, String
			end
			
			action :fetch, DataPage, AuthorizeAttribute[SuperJudgement],
				:page => { :type => Integer, :default => 0 },
				:limit => { :type => Integer, :default => 0 } do |page, limit|
				raise(ArgumentException.new('page', 'Page must be non-negative number!')) if page < 0
				raise(ArgumentException.new('limit', 'Limit must be non-negative number!')) if page < 0
				ret = []
				interconnect.fetch(DbServer).open(DB::RomDbContext) do |ctx|
					enum = ctx.users
					enum = enum.skip(page * limit).take(limit) if limit > 0
					enum.each do |user|
						ret << UserModel.new(:login => user.login, :first_name => user.contact.first_name, :last_name => user.contact.last_name)
					end
					
					next DataPage.new(:items => ret, :total => ctx.users.count)
				end
			end
		end
	end
end