module ROM
	class LogManager
		include Component
		include Logger
		
		def initialize(itc)
			@itc = itc
			@ena = @itc.fetch(LogConfig).enabled
			@loggers = []
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
			@loggers.each { |lg| lg.log(*args) } if @ena
		end
	end
end