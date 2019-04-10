module ROM
	class LogConfig < Config
		def enabled
			@ena
		end

		def initialize(itc)
			super('log', LogModel)
		end

		def load(cfg)
			@ena = cfg.enabled
		end

		class LogModel < Model
			property! :enabled, Types::Boolean[]
		end
	end
end