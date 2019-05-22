# Created by Matyáš Pokorný on 2019-05-22.

module ROM
	module DbSeed
		def self.included(klass)
			klass.instance_variable_set(:@seed, nil)
			klass.extend ClassMethods
		end
		
		module ClassMethods
			def seed(with = nil, &block)
				if block_given?
					raise("'with' must be nil!") unless with == nil
					@seed = block
				else
					with.instance_exec(&@seed) unless @seed == nil
				end
			end
		end
	end
end