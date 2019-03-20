# Created by Matyáš Pokorný on 2019-03-16.

module ROM
	# Main class of the application
	class Application
		# Instantiates the {ROM::Application} class
		# @param [String] data Path to data directory
		# @param [Hash] opt Startup options
		# @option opt [Bool] :debug Indicates how much debug information the application logs
		def initialize(data, **opt)
			raise("Data directory '#{data}' doesn't exist!") unless Dir.exists?(data)
			@data = File.expand_path(data)
			@log  = TextLogger.new(ShortFormatter.new, STDOUT)
			@itc  = Interconnect.new(@log)
			@itc.register(JobServer)
			
			# TODO: Add all interconnect imports
		end
	end
end