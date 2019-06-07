module ROM
	module API
		class LoginController < StaticResource
			namespace :api, :v1
			
			class LoginModel < Model
				property! :username, String
				property! :password, String
			end
			
			class TokenModel < Model
				property! :token, String
			end
			
			class UserModel < Model
				property! :login, String
				property! :name, String
				property! :super, Types::Boolean[]
			end
			
			action :login, String, :body! => LoginModel do |login|
				token = interconnect.fetch(ROM::Authentication::AuthenticationService).resolve(login.username, login.password)
				
				if token != nil
					TokenModel.new(:token => token)
				else
					raise(UnauthenticatedException.new)
				end
			end
			
			action :me, UserModel, AuthorizeAttribute[] do
				UserModel.new(:login => identity.login,:name => identity.user.full_name, :super => identity.super)
			end
		end
	end
end