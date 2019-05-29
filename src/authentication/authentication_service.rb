module ROM
  module Authentication
    class AuthenticationService < ROM::Service

      def initialize(itc)
        super(itc, "Authentication Service", "Authenticates people")
        @authenticators = []

        @token_factories = itc.lookup(ROM::Authentication::Factories::TokenFactory)
        itc.hook(ROM::Authentication::TokenFactory) do |fact|
          @token_factories.push(fact)
        end
        @tok = @token_factories[0].first

        @providers = @itc.lookup(ROM::Authentication::Providers::AuthenticationProvider)
        itc.hook(ROM::Authentication::Providers::AuthenticationProvider) do |prov|
          @providers.push(prov)
        end
      end

      def resolve(username, password)
        user = @authenticators.each do |auth|
          usr = auth.authenticate(username, password)
          break usr unless usr == nil
        end

        return nil  unless user.is_a?(User)

        token = @tok.to_string(@tok.issue_token(user, username, nil))

        return token
      end

      def up
        config = @itc.fetch(AuthenticationConfig)

        @providers = @itc.lookup(AuthenticationProvider)
        itc.hook(AuthenticationProvider) do |prov|
          @providers.push(prov)
        end

        config.onion.each_pair do |name, model|
          provder = @providers.select{|prov| prov.is_name?(name)}.first
          authenticator = provider.open(provider.config_model.from_object(model.config))
          @authenticators.push(authenticator)
        end
      end

      def down
      end
    end
  end
end