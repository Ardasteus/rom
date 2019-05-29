module ROM
  module Authentication
    class TestAuthenticator

      def initiliaze(urs, psw)
      end

      def authenticate(username, password)
        return User.mew("Hello There","Hello", "There")
      end
    end
  end
end