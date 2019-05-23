module ROM
  module API
    class LoginController < StaticResource
      namespace :api, :v1

      class LoginModel < Model
        property! :username, String
        property! :password, String
      end

      action :login, String, :body! => LoginModel do |login|
        interconnect.fetch(AuthenticationService).resolve(login.username, login.password)
      end
    end
  end
end