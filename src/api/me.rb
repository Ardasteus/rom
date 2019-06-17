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
			
			action :contact, ContactsResource::ContactResource do
				db = interconnect.fetch(DbServer).open(DB::RomDbContext)
				
				ContactsResource::ContactResource.new(db, db.protect { db.users.find(identity.id).contact }, true)
			end
			
			action :has_password, Types::Boolean[], AuthorizeAttribute[] do
				has = false
				
				interconnect.fetch(DbServer).open(DB::RomDbContext) do |ctx|
					user = ctx.users.find(identity.id)
					ctx.logins.select { |i| i.user == user }.each do |login|
						has = ctx.passwords.any? { |i| i.login == login }
						break if has
					end
				end
				
				has
			end
			
			action :password, Types::Void, AuthorizeAttribute[], :body! => PasswordModel do |body|
				one = false
				
				interconnect.fetch(DbServer).open(DB::RomDbContext) do |ctx|
					user = ctx.users.find(identity.id)
					ctx.logins.select { |i| i.user == user }.each do |login|
						pwd = ctx.passwords.find(login)
						next if pwd == nil
						raise(UnauthenticatedException.new) unless AUTH.check_hash(pwd.hash, body.old)
						
						pwd.hash = AUTH.get_hash(body.new, AUTH.hash_cost(pwd.hash))
						ctx.passwords.update(pwd)
						login.generation += 1
						ctx.logins.update(login)
						one = true
					end
				end
				
				raise(NotFoundException.new('Password not found!')) unless one
			end
		end
	end
end