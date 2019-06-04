module ROM
  module Authentication
    module Authenticators
    class TestAuthenticator

      def initialize(urs, psw)
      end

      def authenticate(username, password)
        first, last = username.split(" ");
        return User.new(username,first, last)
      end
    end
  end
  end
  end