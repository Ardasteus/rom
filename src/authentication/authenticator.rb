module ROM
  module Authentication
    class Authenticator
      include Component

      def initiliaze(itc)
        @itc = itc
      end

      def authenticate(username, password )

      end
    end
  end
end