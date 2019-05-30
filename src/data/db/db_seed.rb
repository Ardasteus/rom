# Created by Matyáš Pokorný on 2019-05-22.

module ROM
	# Allows DB table models to be seeded
	module DbSeed
		# Invoked when module is included
		# @param [Class] klass Including class
		def self.included(klass)
			klass.instance_variable_set(:@seed, nil)
			klass.extend ClassMethods
		end
		
		# Methods extended into model class
		module ClassMethods
			# @overload seed()
			# 	Sets the seed function
			# 	@yield [] Body of seeding function
			# @overload seed(with)
			# 	Invokes seeding function in given context
			# 	@param [ROM::DbCollection] Collection to seed in
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