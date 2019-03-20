# Created by Matyáš Pokorný on 2019-03-17.

module ROM
	# Base of components
	module Component
		# Invoked when the module is implemented
		# @param [Class] klass Class which implements the module
		# @return [void]
		def self.included(klass)
			klass.extend ClassMethods
		end
		
		# All class methods of components
		module ClassMethods
			# Invoked when component is registered
			# @param [ROM::Interconnect] itc Interconnect which registers the class
			# @return [Array<Object>] Instances to register
			def register(itc)
				[self.new(itc)]
			end
		end
	end
end