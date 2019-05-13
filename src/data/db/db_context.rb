module ROM
	class DbContext
		def tables
			self.class.tables
		end
		
		def convention(nm, *args)
			self.class.convention(nm, *args)
		end
		
		def self.convention(nm, *args, &block)
			if block_given?
				@conv[nm] = block
			else
				@conv[nm]&.call(*args)
			end
		end
		
		def self.tables
			@tabs.values
		end
		
		# Prepares the DB context class
		# @return [void]
		def self.prepare_model
			@tabs = {}
			@conv = {}
		end
		
		# Prepares all subclasses
		# @param [Class] sub Type of subclass
		# @return [void]
		def self.inherited(sub)
			sub.prepare_model
		end
		
		def self.table(name, mod, *att)
			raise("Table '#{name}' already defined!") if @tabs.has_key?(name)
			@tabs[name] = Table.new(name, mod, *att)
		end
		
		class Table
			def name
				@name
			end
			
			def model
				@model
			end
			
			def attributes
				@attributes
			end
			
			def keys
				@keys
			end
			
			def initialize(nm, mod, *att)
				@name = nm
				@model = mod
				@attributes = att
				@keys = mod.properties.select { |i|
					i.attribute?(KeyAttribute) }
				if @keys.size == 0
					id = mod.properties.find { |i| i.name.downcase == 'id' }
					@keys << id  unless id == nil
				end
			end
		end
	end
end