# Created by Matyáš Pokorný on 2019-03-17.

module ROM
	# Connects components together
	class Interconnect
		# Instantiates the {ROM::Interconnect} class
		# @param [Object] log Logger
		def initialize(log)
			@log = log
			@reg = Set.new
		end
		
		# Loads all components in a module
		# @param [Module] mod Module to scan
		# @return [void]
		def load(mod)
			mod.constants.collect { |i| mod.const_get(i) }.select { |i| i.class == Class or i.class == Module }.each do |com|
				register(com) if com.class == Class and com.include?(Component)
				load(com) if com.class == Module
			end
		end
		
		# Registers a components class
		# @param [Class] com Component class
		# @return [void]
		def register(com)
			@log.trace("Importing '#{com.name}'...")
			com.register(self).each(&@reg.method(:add))
		end
		
		# Looks up all components of specified base type
		# @param [Class] type Type to lookup
		# @return [void]
		def lookup(type)
			@reg.select { |i| i.is_a?(type) }
		end
	end
end