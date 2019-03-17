# Created by Matyáš Pokorný on 2019-03-17.

module ROM
	class ShortFormatter
		def entry(sev, msg, ex)
			ret = self.class.unroll('', msg, sev)
			if ex != nil
				ret = self.class.unroll(ret, "<#{ex.class.name}> #{ex.message}", sev, 0, '!')
				ret = self.class.unroll(ret, ex.backtrace.join($/), sev, 1, '!')
			end
			return ret
		end
		
		def self.unroll(bfr, text, sev, offset = 0, pipe = '|')
			text.lines do |ln|
				bfr += (bfr.length == 0 ? sev.name[0].upcase : "\n ") + " #{pipe} " + ('  ' * offset) + ln.chomp.strip
			end
			
			return bfr
		end
	end
end