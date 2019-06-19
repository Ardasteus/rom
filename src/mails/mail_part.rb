# Created by Matyáš Pokorný on 2019-06-18.

module ROM
	class MailPart
		def headers
			@hdr
		end
		
		def data
			@data
		end
		
		def initialize(hdr, data)
			@hdr = hdr
			@data = data
		end
		
		def has_header?(key)
			@hdr.has_key?(key)
		end
		
		def [](key)
			@hdr[key]
		end
		
		def close
			@data.close
		end
	end
end