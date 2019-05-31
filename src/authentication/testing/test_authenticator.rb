module ROM
  module Authentication
    module Authenticators
    class TestAuthenticator

      def initialize(urs, psw)
      end

      def authenticate(username, password)
        return User.new("Hello There","Hello", "There")
      end
    end
  end
  end
  end