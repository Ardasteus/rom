module ROM
  module Authentication

    class AuthenticationConfig < Config
      # Instantiates the {AuthenticationConfig} class
      # @param [Interconnect] itc Interconnect
      def initialize(itc)
        super("ldap", AuthServiceConfig)
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
      class AuthServiceConfig < Model
        property! :type, String
        property! :config, Hash
      end

      class AuthConfig
        property! :services, Types::Hash[String, AuthServiceConfig]
      end
    end
  end
end
