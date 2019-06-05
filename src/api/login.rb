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
				property! :name, String
			end
			
			action :login, String, :body! => LoginModel do |login|
				token = interconnect.fetch(ROM::Authentication::AuthenticationService).resolve(login.username, login.password)
				
				if token != nil
					TokenModel.new(:token => token)
				else
					raise(UnauthenticatedException.new)
				end
			end
			
			action :me, UserModel do
				UserModel.new(:name => user.full_name) if user != nil
			end
		end
	end
end