# Created by Matyáš Pokorný on 2019-03-17.

module ROM
	# Simplistic log entry text formatter
	class ShortFormatter
		# Transforms a log entry into text
		# @param [ROM::Logger::Severity] sev Severity of the log entry
		# @param [String, nil] msg Message of the log entry
		# @param [Exception, nil] ex Exception of the log entry
		# @return [String] String representation of the log entry
		def entry(sev, msg, ex)
			ret = self.class.unroll('', msg, sev)
			if ex != nil
				ret = self.class.unroll(ret, "<#{ex.class.name}> #{ex.message}", sev, 0, '!')
				ret = self.class.unroll(ret, ex.backtrace.join($/), sev, 1, '!') unless ex.backtrace == nil
			end
			return ret
		end
		
		# Formats a block of text
		# @param [String] bfr String to append to
		# @param [String] text Text block to format
		# @param [ROM::Logger::Severity] sev Severity of the block
		# @param [Integer] offset Padding level of the block
		# @param [String] pipe Pipe symbol of the block
		# @return [String] Formatted block
		def self.unroll(bfr, text, sev, offset = 0, pipe = '|')
			text.lines do |ln|
				bfr += (bfr.length == 0 ? sev.name[0].upcase : "\n ") + " #{pipe} " + ('  ' * offset) + ln.chomp.strip
			end
			
			return bfr
		end
	end
end