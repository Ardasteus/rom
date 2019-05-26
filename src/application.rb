# Created by Matyáš Pokorný on 2019-03-16.

module ROM
	# Main class of the application
	class Application
		FILE_CONFIG = 'config.yml'
		DBG_SLEEP = 0.25
		
		# Instantiates the {ROM::Application} class
		# @param [String] data Path to data directory
		# @param [Hash] opt Startup options
		# @option opt [Bool] :debug Indicates that the application is in debug mode
		def initialize(data, **opt)
			raise("Data directory '#{data}' doesn't exist!") unless Dir.exist?(data)
			@data = File.expand_path(data)
			@debug = (opt[:debug] or false)
			@itc = Interconnect.new
			@itc.register(LogServer)
			@log = @itc.fetch(LogServer)
			@log << TextLogger.new(ShortFormatter.new, STDOUT)
			@itc.register(JobServer)
			@itc.register(ApiGateway)
			@itc.register(Filesystem)
			@itc.register(DbServer)
			@itc.register(MySql::MySqlDriver)
			@itc.register(Sqlite::SqliteDriver)
			
			@itc.load(ROM::API)
			@itc.load(ROM::DataSerializers)
			@itc.load(ROM::HTTP)
			@itc.load(ROM::HTTP::Methods)
			
			# TODO: Add all interconnect imports
		end
		
		# Starts the application
		def start
			@log.info('Starting...')
			@log.trace("Rooting file system in '#{@data}'...")
			@itc.fetch(Filesystem).root = Pathname.new(@data)
			@log.trace('Loading configuration...')
			SafeYAML::OPTIONS[:default_mode] = :safe
			conf_f = File.join(@data, FILE_CONFIG)
			unless File.exist?(conf_f)
				ex = Exception.new("Configuration file '#{FILE_CONFIG}' not found!")
				@log.error(ex.message)
				if @debug
					sleep DBG_SLEEP # Wait for debug output to catch up
					raise ex
				else
					return
				end
			end
			
			begin
				conf = SafeYAML.load_file(conf_f)
				@itc.lookup(Config).each do |cfg|
					cfg.load(cfg.model.from_object(conf[cfg.name]))
				end
			rescue Exception => ex
				@log.error("Failed to load configuration from '#{conf_f}'!: #{ex.message}", ex)
				if @debug
					sleep DBG_SLEEP # Wait for debug output to catch up
					raise
				else
					return
				end
			end
			
			@log.info('Starting log servers...')
			@itc.lookup(Service).select { |i| i.is_a?(LogServer) }.sort_by(&method(:dep_level)).each do |svc|
				begin
					svc.start
				rescue Exception => ex
					@log.error("Failed to start log server!: #{ex.message}", ex)
					if @debug
						sleep DBG_SLEEP # Wait for debug output to catch up
						raise
					else
						return
					end
				end
			end
			
			@log.info('Starting services...')
			@itc.lookup(Service).select { |i| not i.is_a?(LogServer) }.sort_by(&method(:dep_level)).each do |svc|
				begin
					svc.start
				rescue Exception => ex
					@log.error("Failed to start service!: #{ex.message}", ex)
					if @debug
						sleep DBG_SLEEP # Wait for debug output to catch up
						raise
					else
						return
					end
				end
			end
			
			@log.info('Started!')
			@log.trace('Suspending master thread...')
			begin
				sleep
			rescue Interrupt
				@log.warning('Interrupted, shutting down...')
				@log.info('Stopping services...')
				clean = true
				@itc.lookup(Service).select { |i| not i.is_a?(LogServer) }.sort_by { |svc| -dep_level(svc) }.each do |svc|
					begin
						svc.stop
					rescue Exception => ex
						clean = false
						@log.error("Service failed to stop!: #{ex.message}", ex)
						if @debug
							sleep DBG_SLEEP
							raise
						end
					end
				end
				
				@log.trace('Stopping log servers...')
				@itc.lookup(Service).select { |i| i.is_a?(LogServer) }.sort_by { |svc| -dep_level(svc) }.each do |svc|
					begin
						svc.stop
					rescue Exception => ex
						clean = false
						@log.error("Service failed to stop!: #{ex.message}", ex)
						if @debug
							sleep DBG_SLEEP
							raise
						end
					end
				end
				@log.trace('Application successfully stopped!') if clean
			rescue Exception => ex
				@log.error("An unhandled exception was raised!: #{ex.message}", ex)
				if @debug
					sleep DBG_SLEEP # Wait for debug output to catch up
					raise
				end
			end
		end
		
		def dep_level(svc)
			(svc.dependencies.collect { |klass| dep_level(@itc.fetch(klass)) }.max or 0) + 1
		end
		
		private :dep_level
	end
end