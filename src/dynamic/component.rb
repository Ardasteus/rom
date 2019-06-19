# Created by Matyáš Pokorný on 2019-03-17.

module ROM
	# Base of components
	module Component
		# Invoked when the module is implemented
		# @param [Class] klass Class which implements the module
		# @return [void]
		def self.included(klass)
			super(klass)
			
			klass.extend ClassMethods
			setup_modifiers(klass)
		end
		
		def self.setup_modifiers(klass)
			klass.instance_variable_set(:@mod, [])
			
			klass.define_singleton_method :modifiers do |*mods|
				klass.instance_variable_set(:@mod, mods)
			end
			
			klass.define_singleton_method :modifier? do |mod|
				klass.instance_variable_get(:@mod).include?(mod)
			end
			
			klass.define_singleton_method :inherited do |other|
				super(other)
				
				Component.setup_modifiers(other)
			end
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