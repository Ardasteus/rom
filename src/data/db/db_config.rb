# Created by Matyáš Pokorný on 2019-05-27.

module ROM
	# Represents the 'db' configuration section
	class DbConfig < Config
		# Instantiates the {ROM::DbConfig} component class
		# @param [ROM::Interconnect] itc Component registering interconnect
		def initialize(itc)
			super("db", ConfigModel)
			@cfg = nil
		end
		
		# Gets context configurations
		# @return [Hash{String=>ROM::DbConfig::ContextModel}] Configured context configurations
		def dbs
			@cfg.databases
		end
		
		# Gets a specific context configuration
		# @param [String, Symbol] name Name of context to fetch the configuration of
		# @return [ROM::DbConfig::ContextModel] Context configuration
		def db(name)
			@cfg.databases[name.to_s]
		end
		
		# Loads the configuration from instance of the configuration section model
		# @param [ROM::DbConfig::ContextModel] cfg Instance of configuration section model
		def load(cfg)
			@cfg = cfg
		end
		
		# Model of a DB context configuration
		class ContextModel < Model
			property! :driver, String
			property :connection, Hash, {}
		end
		
		# Model of the 'db' configuration section
		class ConfigModel < Model
			property :databases, Types::Hash[String, ContextModel], {}
		end
	end
end