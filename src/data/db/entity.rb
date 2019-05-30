# Created by Matyáš Pokorný on 2019-05-18.

module ROM
	# Wraps a model. Adds support for lazy loading and change tracking
	class Entity
		# Gets the changes made to the entity
		# @return [Hash{Symbol=>[Object,nil]}] Changed properties
		def entity_changes
			@changes
		end
		
		# Gets the table that manages the entity
		# @return [ROM::DbTable] Table of the entity
		def entity_table
			@tab
		end
		
		# Gets the underlying model instance
		# @return [ROM::Model] Wrapped model instance
		def entity_model
			@mod
		end
		
		# Checks whether entity was changed
		# @return [Boolean] True if entity was changed; false otherwise
		def entity_changed?
			@changes.size > 0
		end
		
		# Gets all entity changes, and clears the tracking list
		# @return [Hash{Symbol=>[Object,nil]}] Changed properties before they were cleared
		def flush_changes
			ret = @changes
			@changes = {}
			
			ret
		end
		
		# Instantiates the {ROM::Entity} class
		# @param [ROM::DbTable] tab Table which manages the entity
		# @param [Hash{Symbol=>[Object, nil]}] vals Values of entity
		def initialize(tab, vals = {})
			@tab = tab
			@changes = {}
			
			ctr = {}
			tab.table.model.properties.each do |prop|
				sym = prop.name.to_sym
				v = vals[sym]
				
				if v.is_a?(LazyPromise)
					got = false
					self.class.send(:define_method, sym) do
						if got
							@mod[sym]
						else
							i = v.fetch
							@mod[sym] = i
							got = true
							
							i
						end
					end
					
					fake = Module.new
					fake.define_singleton_method :is_a? do |klass|
						prop.type <= klass
					end
					ctr[sym] = fake
				else
					self.class.send(:define_method, sym) { @mod[sym] }
				end
				
				self.class.send(:define_method, "#{sym.to_s}=".to_sym) do |val|
					if @mod[sym] != val
						@changes[sym] = val
						@mod[sym] = val
					end
				end
			end
			
			vals.each_pair do |k, v|
				ctr[k] = v unless v.is_a?(LazyPromise)
			end
			@mod = tab.table.model.new(ctr)
		end
		
		# Fetches property of model
		# @param [Symbol, String] key Name of property to fetch
		# @return [Object, nil] Fetched value of given property
		def [](key)
			@mod[key]
		end
		
		# Sets property to a given value
		# @param [Symbol, String] key Name of property to set
		# @param [Object, nil] value Value to set the property to
		def []=(key, value)
			@mod[key] = value
		end
		
		def method_missing(name, *args, &block)
			@mod.send(name, *args, &block)
		end
		
		# Ensures that the entity is accepted as subtype of the wrapped model
		# @param [Class] klass Class to check the type of this entity against
		# @return [Boolean] True if entity is of given type; false otherwise
		def is_a?(klass)
			self.class <= klass or @mod.is_a?(klass)
		end
	end
end