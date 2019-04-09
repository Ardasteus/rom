module ROM
  module HTTP
    class HTTPConfig < Config
      # Instantiates the {HTTPConfig} class
      # @param [Interconnect] itc Interconnect
      def initialize(itc)
        super("http", ConfigModel)
      end

      def bind
        @bind
      end

      # Loads the http server bindings from a config file
      # @param [Config] config Config file
      def load(config)
        @bind = config.binding
      end

      class BindingModel < Model
        property! :address, String
        property :port, Integer, 80
        property :https, Types::Boolean[], false
        property :cert_path, String
        property :redirect, String
      end

      # Model defining the properties of {HTTPConfig} class
      class ConfigModel < Model
        property :binding, Types::Array[BindingModel], []
      end
    end
  end
end