module ROM
  module API
    class LoginController < StaticResource
      namespace :api, :v1

      class LoginModel < Model
        property! :user, String
        property! :pwd, String
      end

      action :login, String, :body! => LoginModel do |login|
        "#{login.user} : #{login.pwd}"
      end
    end
  end
end