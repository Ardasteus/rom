module ROM
  module HTTP

    # Config used to initiliaze all HTTP servers with the given parameters in a config file
    class HTTPConfig < Config
      # Instantiates the {HTTPConfig} class
      # @param [Interconnect] itc Interconnect
      def initialize(itc)
        super("http", ConfigModel)
      end

      # Bound data
      # @return [BindingModel]
      def bind
        @bind
      end

      # Loads the http server bindings from a config file
      # @param [Config] config Config file
      def load(config)
        @bind = config.binding
      end

      # Model defining the data binding
      class BindingModel < Model
        property! :address, String
        property :port, Integer, 80
        property :https, Types::Boolean[], false
        property :cert_path, String
				property :key_path, String
        property :redirect, String
				
				def hash
					Digest::SHA1.hexdigest("#{address}:#{port}:#{redirect}")[0..15]
				end
      end

      # Model defining the properties of {HTTPConfig} class
      class ConfigModel < Model
        property :binding, Types::Array[BindingModel], []
      end
    end
  end
end