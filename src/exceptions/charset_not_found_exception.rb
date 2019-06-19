# Created by Matyáš Pokorný on 2019-06-05.

module ROM
	class CharsetNotFoundException < ApiException
		def initialize(charset)
			super("Charset '#{charset}' not found!")
		end
	end
end