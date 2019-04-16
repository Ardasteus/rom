module ROM
  module Authentication
    class AuthenticationResolver < ROM::Service

      def initialize(itc)
        super(itc, "Authentication Service", "Authenticates people")
        @authenticators = itc.lookup(Authenticator)
        itc.hook(Authenticator) do |auth|
          @authenticators.push(auth)
        end
      end

      def resolve(username, password)
        state = :failed
        @authenticators.each do |auth|
          state = auth.authenticate(username, password) if state == :failed
        end
        return state
      end
    end
  end
end