# Created by Matyáš Pokorný on 2019-03-16.

module ROM
	# Main class of the application
	class Application
		FILE_CONFIG = 'config.yml'
		
		# Instantiates the {ROM::Application} class
		# @param [String] data Path to data directory
		# @param [Hash] opt Startup options
		# @option opt [Bool] :debug Indicates how much debug information the application logs
		def initialize(data, **opt)
			raise("Data directory '#{data}' doesn't exist!") unless Dir.exists?(data)
			@data = File.expand_path(data)
			@log  = TextLogger.new(ShortFormatter.new, STDOUT)
			@itc  = Interconnect.new(@log)
			@itc.register(JobServer)
			@itc.register(HTTPServer)
			@itc.lookup(HTTPServer).each(&:run)
			
			# TODO: Add all interconnect imports
		end
		
		# Starts the application
		def start
			@log.info('Starting...')
			@log.trace('Loading configuration...')
			SafeYAML::OPTIONS[:default_mode] = :safe
			conf = File.join(@data, FILE_CONFIG)
			raise("Configuration file '#{FILE_CONFIG}' not found!") unless File.exists?(conf)
			conf = SafeYAML.load_file(conf)
			@itc.lookup(Config).each do |cfg|
				cfg.load(cfg.model.from_object(conf[cfg.name]))
			end
			
			@log.trace('Starting services...')
			@itc.lookup(Service).each(&:start)
			
			@log.trace('Suspending master thread...')
			sleep
		end
	end
end