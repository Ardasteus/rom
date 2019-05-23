module ROM
  module Authentication

    class AuthenticationConfig < Config
      # Instantiates the {AuthenticationConfig} class
      # @param [Interconnect] itc Interconnect
      def initialize(itc)
        super("ldap", AuthConfigModel)
      end

      # Bound data
      # @return [BindingModel]
      def bind
        @bind
      end

      # @param [Config] config Config file
      def load(config)
        @bind = config.binding
      end

      # Model defining the data binding
      class AuthConfigModel < Model
        property! :token_lifetime, String
        property! :rsa_size, String
        property! :services, Hash
      end

      class AuthConfig
        property! :services, Types::Hash[String, Hash]
      end
    end
  end
end
