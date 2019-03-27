# Created by Matyáš Pokorný on 2019-03-17.

module ROM
	# Connects components together
	class Interconnect
		# Instantiates the {ROM::Interconnect} class
		# @param [Object] log Logger
		def initialize(log)
			@log = log
			@reg = Set.new
			@hooks = []
		end

		def hook(type, &block)
			@log.trace("Setting interconnect hook for '#{type.name}'...")
			@hooks << { :type => type, :hook => block }
		end
		
		# Loads all components in a module
		# @param [Module] mod Module to scan
		# @return [void]
		def load(mod)
			mod.constants.collect { |i| mod.const_get(i) }.select { |i| i.is_a?(Module) }.each do |com|
				register(com) if com.is_a?(Class) and com.include?(Component)
				load(com) if com.class == Module
			end
		end
		
		# Registers a components class
		# @param [Class] com Component class
		# @return [void]
		def register(com)
			@log.trace("Importing '#{com.name}'...")
			hooks = @hooks.collect { |i| com < i.type }
			com.register(self).each do |i| 
				@reg << i
				hooks.each { |h| h[:hook].call(i) }
			end
		end
		
		# Looks up all components of specified base type
		# @param [Class] type Type to lookup
		# @return [void]
		def lookup(type)
			@reg.select { |i| i.is_a?(type) }
		end
	end
end