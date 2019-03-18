# Created by Matyáš Pokorný on 2019-03-17.

module ROM
	class Interconnect
		def initialize(log)
			@log = log
			@reg = Set.new
		end
		
		def load(mod)
			mod.constants.collect { |i| mod.const_get(i) }.select { |i| i.class == Class or i.class == Module }.each do |com|
				register(com) if com.class == Class and com.include?(Component)
				load(com) if com.class == Module
			end
		end
		
		def register(com)
			@log.trace("Importing '#{com.name}'...")
			com.register(self).each(&@reg.method(:add))
		end
		
		def lookup(type)
			@reg.select { |i| i.is_a?(type) }
		end
	end
end