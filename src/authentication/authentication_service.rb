module ROM
  module Authentication
    class AuthenticationService < ROM::Service

      def initialize(itc)
        super(itc, "Authentication Service", "Authenticates people")
        @authenticators = []

        @providers = @itc.lookup(ROM::Authentication::AuthenticationProvider)
        itc.hook(ROM::Authentication::AuthenticationProvider) do |prov|
          @providers.push(prov)
        end

        @itc = itc
      end

      def resolve(username, password)
        user = @authenticators.each do |auth|
          usr = auth.authenticate(username, password)
          break usr unless usr == nil
        end

        return nil  unless user.is_a?(User)

        tok = @itc.fetch(ROM::Authentication::TokenFactory)
        token = tok.to_string(tok.issue_token(user, username, nil))

        return token
      end

      def up
        config = @itc.fetch(AuthenticationConfig).config

        config.onion.each_pair do |name, model|
          provider = @providers.select{|prov| prov.is_name?(name)}.first
          authenticator = provider.open(provider.config_model.from_object(model.config))
          @authenticators.push(authenticator)
        end
      end

      def down
      end
    end
  end
end