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
		
		def initialize(tab)
			@mod = tab.table.model
			@tab = tab
			@changes = {}
			
			@mod.properties.each do |prop|
				sym = prop.name.to_sym
				
				define_method(sym) { @mod[sym] }
				agn = "#{sym.to_s}=".to_sym
				if prop.type < Model
					raise('References are not supported yet!')
				else
					define_method(agn) do |val|
						if @mod[sym] != val
							@changes[sym] = val
							@mod[sym] = val
						end
					end
				end
			end
		end
		
		def [](key)
			@mod[key]
		end
		
		def []=(key, value)
			@mod[key] = value
		end
		
		def is_a?(klass)
			self.is_a?(klass) or @mod.class.is_a?(klass)
		end
	end
end