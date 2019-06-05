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
        property! :username, String
      end

      action :login, String, :body! => LoginModel do |login|
        token = interconnect.fetch(ROM::Authentication::AuthenticationService).resolve(login.username, login.password)
				
				TokenModel.new(:token => token)
      end

      action :me, UserModel do
        UserModel.new(:username => user.full_name) if user != nil
      end
    end
  end
end