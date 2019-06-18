# Created by Matyáš Pokorný on 2019-06-18.

module ROM
	class BoundedIO
		EMPTY = ''.encode(Encoding::ASCII_8BIT)
		
		def initialize(io, len)
			@pos = 0
			@len = len
			@io = io
		end
		
		def length
			@len
		end
		
		def pos
			@pos
		end
		
		def pos=(val)
			@io.pos += val - @pos
		end
		
		def seek(len, orig)
			case orig
				when IO::SEEK_CUR
					raise(Exception.new('Out of IO bounds!')) if pos + len > @len
					pos += @orig
				when IO::SEEK_END
					raise(Exception.new('Out of IO bounds!')) if len > @len
					pos = @len - len
				when IO::SEEK_SET
					raise(Exception.new('Out of IO bounds!')) if len > @len
					pos = len
				else
					raise(Exception.new('Unknown seek!'))
			end
		end
		
		def read(len = nil, buf = nil)
			return EMPTY if len == 0
			if pos >= @len
				return (len == nil ? EMPTY : nil)
			end
		
			n = len == nil ? @len - pos : [len, @len - pos].min
			ret = @io.read(n, buf)
			@pos += n
			
			ret
		end
	end
end