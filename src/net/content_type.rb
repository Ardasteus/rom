# Created by Matyáš Pokorný on 2019-06-05.

module ROM
	class ContentType
		def type
			@type
		end
		
		def options
			@opt
		end
		
		def charset
			@opt[:charset]
		end
		
		def boundary
			@opt[:boundary]
		end
		
		def initialize(tp, **opt)
			@type = tp.downcase
			@opt = opt.collect { |kvp| [kvp[0], kvp[1].downcase] }.to_h
		end
		
		def to_s
			opt = ''
			@opt.each_pair { |k, v| opt += "; #{k}=#{(v.include?(';') or v.include?(' ')) ? "\"#{v}\"" : v}" }
			"#{@type}#{opt}"
		end
		
		def self.from_header(hdr)
			spl = hdr.split(';')
			opt = {}
			spl.drop(1).collect { |i| i.split('=', 2).collect(&:strip) }.each do |kvp|
				v = kvp[1]
				opt[kvp[0].downcase.to_sym] = ((v.start_with?('"') and v.end_with?('"')) ? v[1..v.length - 2] : v)
			end
			
			self.new(spl[0], **opt)
		end
	end
end