module ROM
  module Authentication
    class LDAPAuthenticator < Authenticator
      include Component

      def initiliaze(itc)
        @itc = itc
        @config = itc.fetch(AuthenticationConfig)
      end

      def authenticate(username, password)
        ldap = Net::LDAP.new
        config_bind = @config.bind[0]
        dc = config_bind.host.split(".")
        filter = Net::LDAP::Filter.eq( "samaccountname", username )
        attrs = ["givenname", "surname"]
        search_base = "OU=users"
        dc.each do |part|
          search_base += ", DC=#{part}"
        end
        ldap.host = config_bind.host
        ldap.port = config_bind.port
        ldap.auth username, password
        if ldap.bind
          user_info = ldap.search(:base => search_base, :filter => filter, :attributes => attrs,
                      :return_result => true).first
          first = user_info.givenName
          last = user_info.lastName
          user = new ROM::Authentication::User(username, nil, first, last)
        end
        return user
      end
    end
  end
end