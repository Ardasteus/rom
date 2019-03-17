# Created by Matyáš Pokorný on 2019-03-17.

module ROM
	# Common methods of flat-sequential loggers
	module Logger
		# Logs a {ROM::Logger::Severity::TRACE} level message
		# @param [String] msg Message of entry
		# @param [Exception, nil] ex Exception of entry
		# @return [void]
		def trace(msg, ex = nil)
			; log(Severity::TRACE, msg || '', ex);
		end
		
		# Logs a {ROM::Logger::Severity::DEBUG} level message
		# @param [String] msg Message of entry
		# @param [Exception, nil] ex Exception of entry
		# @return [void]
		def debug(msg, ex = nil)
			; log(Severity::DEBUG, msg || '', ex);
		end
		
		# Logs a {ROM::Logger::Severity::INFO} level message
		# @param [String] msg Message of entry
		# @param [Exception, nil] ex Exception of entry
		# @return [void]
		def info(msg, ex = nil)
			; log(Severity::INFO, msg || '', ex);
		end
		
		# Logs a {ROM::Logger::Severity::WARNING} level message
		# @param [String] msg Message of entry
		# @param [Exception, nil] ex Exception of entry
		# @return [void]
		def warning(msg, ex = nil)
			; log(Severity::WARNING, msg || '', ex);
		end
		
		# Logs a {ROM::Logger::Severity::ERROR} level message
		# @param [String] msg Message of entry
		# @param [Exception, nil] ex Exception of entry
		# @return [void]
		def error(msg, ex = nil)
			; log(Severity::ERROR, msg || '', ex);
		end
		
		# Logs a {ROM::Logger::Severity::FATAL} level message
		# @param [String] msg Message of entry
		# @param [Exception, nil] ex Exception of entry
		# @return [void]
		def fatal(msg, ex = nil)
			; log(Severity::FATAL, msg || '', ex);
		end
		
		# Logs a message
		# @param [ROM::Logger::Severity] severity Severity of entry
		# @param [String] msg Message of entry
		# @param [Exception, nil] ex Exception of entry
		# @return [void]
		def log(severity, msg, ex)
			raise('Method no implemented!')
		end
		
		# Represents a log entry severity
		class Severity
			include Comparable
			
			# Gets level of severity
			# @return [Integer] Level of severity
			def level;
				@lvl;
			end
			
			# Gets name of severity
			# @return [String] Name of severity
			def name;
				@name;
			end
			
			# Instantiates the {ROM::Logger::Severity} class
			# @param [Integer] lvl Level of severity
			# @param [String] nm Name of severity
			def initialize(lvl, nm)
				@lvl  = lvl
				@name = nm
			end
			
			# Compares severity levels using the spaceship operator
			# @param [ROM::Logger::Severity] other Right-side operand
			# @return [Integer] -1 if level of this severity is lower than the given other operand. 0 if they are the same and 1 if this level is greater
			def <=>(other)
				@lvl <=> other.level
			end
			
			# Converts name to severity
			# @param [String] s Name of severity
			# @return [ROM::Logger::Severity, nil] Severity if found; nil otherwise
			def self.from_s(s)
				self.constants.collect { |i| self.const_get(i) }.select { |i| i.is_a?(self) }.each do |i|
					return i if i.name == s.downcase
				end
				return nil
			end
			
			# TRACE (level 0) severity
			TRACE = self.new(0, 'trace')
			# DEBUG (level 1) severity
			DEBUG = self.new(1, 'debug')
			# INFO (level 2) severity
			INFO = self.new(2, 'info')
			# WARNING (level 3) severity
			WARNING = self.new(3, 'warning')
			# ERROR (level 4) severity
			ERROR = self.new(4, 'error')
			# FATAL (level 5) severity
			FATAL = self.new(5, 'fatal')
		end
	end
end