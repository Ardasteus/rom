module ROM
  class HTTPConfig < Config
    def initialize(itc)
      super("http", ConfigModel)
    end

    def bind
      @bind
    end

    def load(config)
      @bind = config.binding
    end

		class BindingModel < Model
			property! :address, String
			property :port, Integer
			property :https, Types::Boolean[], false
			property :cert_path, String
		end
		
    class ConfigModel < Model
      property :binding, Types::Array[BindingModel], []
    end
  end
end