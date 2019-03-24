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

    class ConfigModel < Model
      property(:binding, Types::Array[String], [])
    end
  end
end