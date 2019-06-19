# Created by Matyáš Pokorný on 2019-04-12.

module ROM
	# Represents a RAM buffer-based logger (thread-safe)
	class BufferLogger
		include Logger
		
		# Instantiates the {ROM::BufferLogger} class
		# @param [Array] bfr Buffer to log into
		def initialize(bfr = [])
			@bfr = bfr
			@mtx = Mutex.new
		end
		
		# Writes the buffer into the given logger
		# @param [ROM::Logger] log Logger to write into
		def push(log)
			@mtx.synchronize { @bfr.each { |e| log.log(*e) } }
		end
		
		# Writes the buffer into the given logger and clears the buffer
		# @param [ROM::Logger] log Logger to write into
		def flush(log)
			@mtx.synchronize do
				@bfr.each { |e| log.log(*e) }
				@bfr = nil
			end
		end
		
		# Adds message to the buffer
		def log(*args)
			@mtx.synchronize { @bfr << args }
		end
	end
end