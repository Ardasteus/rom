# Created by Matyáš Pokorný on 2019-06-04.

module ROM
	class ArgumentException < ApiException
		def initialize(arg, err)
			super("Argument error for '#{arg}'!: #{err}")
		end
	end
end