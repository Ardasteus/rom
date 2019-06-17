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

      # @param [Config] conf Config file
      def load(conf)
        @config = conf
      end

      class AuthConfig < Model
        property! :driver, String
        property! :config, Hash
				property :import, Types::Boolean[], true
      end

			class TokensConfigModel < Model
				property! :factory, String
				property :lifetime, Integer, 8 * 60 * 60
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
