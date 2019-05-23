module ROM
  module Authentication
    class AuthenticationResolver < ROM::Service

      def initialize(itc)
        super(itc, "Authentication Service", "Authenticates people")
        @resolver 
        @authenticators = itc.lookup(Authenticator)
        itc.hook(Authenticator) do |auth|
          @authenticators.push(auth)
        end

        @token_factories = itc.lookup(TokenFactory)
        itc.hook(TokenFactory) do |fact|
          @token_factories.push(fact)
        end
      end

      def resolve(username, password)
        user = @authenticators.each do |auth|
          usr = auth.authenticate(username, password)
          break usr unless usr == nil
        end

        return nil  unless user.is_a?(User)

        token = @token_factories[0].issue_token(user, username, nil)

        return token
      end

      def up
      end

      def down
      end
    end
  end
end