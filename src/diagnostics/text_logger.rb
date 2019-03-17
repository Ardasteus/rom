# Created by Matyáš Pokorný on 2019-03-17.

module ROM
# Flat-sequential text stream logger
	class TextLogger
		include Logger
		
		# Instantiates the {ROM::TextLogger} class
		# @param [Object] format Log entry to text transformer
		# @param [IO] io Stream to write to
		# @param [string] coding Coding of the text
		# @param [string] eol End of line sequence
		def initialize(format, io, coding = Encoding::UTF_8, eol = $/)
			@format = format
			@io     = io
			@coding = coding
			@eol    = eol
		end
		
		# Writes a message into the stream
		# @param [ROM::Logger::Severity] severity Severity of entry
		# @param [String] msg Message of entry
		# @param [Exception, nil] ex Exception of entry
		# @return [void]
		def log(severity, msg, ex)
			@io.write((@format.entry(severity, msg, ex).lines.collect(&:chomp).join(@eol) + @eol).encode(@coding))
		end
	end
end