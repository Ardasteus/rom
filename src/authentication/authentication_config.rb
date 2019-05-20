module ROM
  module Authentication

    class AuthenticationConfig < Config
      # Instantiates the {AuthenticationConfig} class
      # @param [Interconnect] itc Interconnect
      def initialize(itc)
        super("ldap", ConfigModel)
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
      class BindingModel < Model
        property! :host, String
        property :port, Integer, 389


      # Model defining the properties of {AuthenticationConfig} class
      class ConfigModel < Model
        property :binding, Types::Array[BindingModel], []
      end
    end
  end
end
