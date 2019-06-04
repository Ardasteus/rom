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

      class AuthConfig < Model
        property! :config, Hash
      end

			class TokensConfigModel < Model
				property! :factory, String
				property :config, Hash, {}
			end
			
      # Model defining the data binding
      class AuthConfigModel < Model
				property! :tokens, TokensConfigModel
        property! :onion, Types::Hash[String, AuthConfig]
      end
    end
  end
end
