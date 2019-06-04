module ROM
  module Authentication
    module Authenticators
    class LDAPAuthenticator < Authenticator

      def initialize(host, port)
        @host = host
        @port = port
      end

      def authenticate(username, password)
        ldap = Net::LDAP.new
        dc = @host.split(".")
        filter = Net::LDAP::Filter.eq( "samaccountname", username )
        attrs = ["givenname", "surname", "fullname"]
        search_base = "OU=users"
        dc.each do |part|
          search_base += ", DC=#{part}"
        end
        ldap.host = @host
        ldap.port = @port
        ldap.auth username, password
        if ldap.bind
          user_info = ldap.search(:base => search_base, :filter => filter, :attributes => attrs,
                      :return_result => true).first
          first = user_info.givenName
          last = user_info.lastName
          full = user_info.fullName
          user = ROM::Authentication::User.new(full, first, last)
        end
        return user
      end
    end
  end
  end
  end