# Created by Matyáš Pokorný on 2019-05-27.

module ROM
	class DbConfig < Config
		def initialize(itc)
			super("db", ConfigModel)
			@cfg = nil
		end
		
		def dbs
			@cfg.databases
		end
		
		def db(name)
			@cfg.databases[name.to_s]
		end
		
		def load(config)
			@cfg = config
		end
		
		class ContextModel < Model
			property! :driver, String
			property :connection, Hash, {}
		end
		
		class ConfigModel < Model
			property :databases, Types::Hash[String, ContextModel], {}
		end
	end
end