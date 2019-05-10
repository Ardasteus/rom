module ROM
	# A service which provides the application with logging capabilities
	class LogServer < Service
		include Logger
		
		# Instantiates the {ROM::LogServer} class
		# @param [ROM::Interconnect] itc Interconnect which registers this instance
		def initialize(itc)
			super(itc, 'Log server', 'Central logging service')
			@itc = itc
			@loggers = []
			@live = false
			@buffer = []
			@mtx = Mutex.new
		end

		# Flushes the log server buffer
		def flush
			@mtx.synchronize do
				@buffer.each { |i| entry(*i) }
				@buffer = []
			end
		end

		# Stops buffering and enters live mode
		def stop_buffer
			@live = true
		end

		# Leaves live mode and starts buffering
		def start_buffer
			@live = false
		end

		# Starts the service
		def up
			flush
			stop_buffer
		end

		# Stops the service
		def down
			start_buffer
		end

		# Adds a logger
		# @param [ROM::Logger] lg Logger to add
		def <<(lg)
			@loggers << lg
		end
		
		# Writes a message into the stream
		# @param [ROM::Logger::Severity] severity Severity of entry
		# @param [String] msg Message of entry
		# @param [Exception, nil] ex Exception of entry
		# @return [void]
		def log(*args)
			@mtx.synchronize do
				if @live
					entry(*args)
				else
					@buffer << args
				end
			end
		end

		def entry(*args)
			@loggers.each { |lg| lg.log(*args) }
		end

		private :entry
	end
end