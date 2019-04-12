# Created by Matyáš Pokorný on 2019-04-12.

module ROM
	class BufferLogger
		include Logger
		
		def initialize(bfr = [])
			@bfr = bfr
			@mtx = Mutex.new
		end
		
		def push(log)
			@mtx.synchronize { @bfr.each { |e| log.log(*e) } }
		end
		
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