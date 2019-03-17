# Created by Matyáš Pokorný on 2019-03-16.

module ROM
	class Application
		def initialize(data, **opt)
			raise("Data directory '#{data}' doesn't exist!") unless Dir.exists?(data)
			@data = File.expand_path(data)
			@log  = TextLogger.new(ShortFormatter.new, STDOUT)
		end
	end
end