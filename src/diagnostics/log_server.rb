module ROM
	class LogServer < Service
		include Component
		include Logger
		
		def initialize(itc)
			super(itc, 'Log server', 'Central logging service')
			@itc = itc
			@loggers = []
			@live = false
			@buffer = []
			@mtx = Mutex.new
		end

		def flush
			@mtx.synchronize do
				@buffer.each { |i| entry(*i) }
				@buffer = []
			end
		end

		def stop_buffer
			@live = true
		end

		def start_buffer
			@live = false
		end

		def up
			flush
			stop_buffer
		end

		def down
			start_buffer
		end

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