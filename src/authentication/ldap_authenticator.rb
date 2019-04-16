module ROM
  module Authentication
    class LDAPAuthenticator < Authenticator
      include Component

      def initiliaze(itc)
        @itc = itc
      end

      def authenticate(username, password)
        ldap = Net::LDAP.new
        ldap.host = 'localhost'
        ldap.port = 389
        ldap.auth username, password
        if ldap.bind
          state = :authenticated
        else
          state = :failed
        end
        return state
      end
    end
  end
end