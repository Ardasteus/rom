module ROM
  module Authentication

    class AuthenticationConfig < Config
      # Instantiates the {AuthenticationConfig} class
      # @param [Interconnect] itc Interconnect
      def initialize(itc)
        super("authentication", AuthConfigModel)
      end

      # Bound data
      # @return [BindingModel]
      def config
        @config
      end

      # @param [Config] config Config file
      def load(conf)
        @config = conf
      end

      # Model defining the data binding
      class AuthConfigModel < Model
        property! :token_lifetime, Integer
        property! :rsa_size, Integer
        property! :onion, Types::Hash[String, AuthConfig]
      end

      class AuthConfig < Model
        property! :config, Hash
      end
    end
  end
end
