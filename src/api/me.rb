# Created by Matyáš Pokorný on 2019-06-11.

module ROM
	module API
		class MeController < StaticResource
			AUTH = Authentication::Authenticators::LocalAuthenticator
			
			namespace :api, :v1, :me
			
			class UserModel < Model
				property! :login, String
				property! :name, String
				property! :super, Types::Boolean[]
			end
			
			class PasswordModel < Model
				property! :old, String
				property! :new, String
			end
			
			action :fetch, UserModel, AuthorizeAttribute[] do
				UserModel.new(:login => identity.login, :name => identity.user.full_name, :super => identity.super)
			end
			
			action :password, Types::Void, AuthorizeAttribute[], :body! => PasswordModel do |body|
				interconnect.fetch(DbServer).open(DB::RomDbContext) do |ctx|
					user = ctx.users.find { |i| i.login == identity.login }
					ctx.logins.select { |i| i.user == user }.each do |login|
						pwd = ctx.passwords.find { |i| i.login == login }
						next if pwd == nil
						raise(UnauthenticatedException.new) unless AUTH.check_hash(pwd.hash, body.old)
						
						pwd.hash = AUTH.get_hash(body.new, AUTH.hash_cost(pwd.hash))
						ctx.passwords.update(pwd)
						login.generation += 1
						ctx.logins.update(login)
					end
				end
			end
		end
	end
end