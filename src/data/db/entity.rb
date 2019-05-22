# Created by Matyáš Pokorný on 2019-05-18.

module ROM
	class Entity
		def entity_changed?
			@changes.size > 0
		end
		
		def entity_changes
			@changes
		end
		
		def entity_table
			@tab
		end
		
		def entity_model
			@mod
		end
		
		def entity_changed?
			@changes.size > 0
		end
		
		def flush_changes
			ret = @changes
			@changes = {}
			
			ret
		end
		
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
		
		def [](key)
			@mod[key]
		end
		
		def []=(key, value)
			@mod[key] = value
		end
		
		def is_a?(klass)
			self.class <= klass or @mod.is_a?(klass)
		end
	end
end