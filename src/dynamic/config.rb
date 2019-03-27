# Created by Matyáš Pokorný on 2019-03-23.

module ROM
	# Represents a configuration section
	#
	# @example Configuration section 'my'
	# 	class MyConfig < Config
	# 		def name
	# 			@name
	# 		end
	#
	# 		def initialize(itc)
	# 			super('my', ConfModel)
	# 			@name = nil
	# 		end
	#
	# 		def load(cfg)
	# 			@name = cfg.name
	# 		end
	#
	# 		class ConfModel < Model
	# 			property! :name, String
	# 		end
	# 	end
	class Config
		include Component
		
		# Gets the name of configuration section
		# @return [String] Name of configuration section
		def name
			@name
		end
		
		# Gets the model class of configuration section
		# @return [Class] Model class of configuration section
		def model
			@mod
		end
		
		# Instantiates the {ROM::Config} class
		# @param [String] name Name of configuration section
		# @param [Class] mod Model class of configuration section
		# @see ROM::Model
		def initialize(name, mod)
			@name = name
			@mod = mod
		end
		
		# Loads the configuration from instance of the configuration section model
		# @param [Model] cfg Instance of configuration section model
		# @abstract
		def load(cfg)
			raise('Method not implemented!')
		end
	end
end