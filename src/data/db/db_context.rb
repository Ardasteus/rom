module ROM
	class DbContext
		def initialize(db, sch)
			@db = db
			@sch = sch
			@lazy = {}

			@sch.tables.each do |tab|
				map = EntityMapper.new(tab,)
				col = TableCollection.new(db, tab, )
				define_method tab.name.to_sym do

				end
			end
		end

		def lazy(tab)
			if not @lazy.has_key?(tab)
				
			else
				@lazy[tab]
			end
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
			name = name.to_s
			raise("Table '#{name}' already defined!") if @tabs.has_key?(name)
			@tabs[name] = Table.new(name, mod, *att)
		end

		private :lazy
		
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
				@keys = mod.properties.select { |i|	i.attribute?(KeyAttribute) }
				if @keys.size == 0
					id = mod.properties.find { |i| i.name.downcase == 'id' }
					@keys << id  unless id == nil
				end
			end
		end
		
		class TableCollection < DbCollection
			def initialize(db, tab, map)
				@db = db
				@tab = tab
				@map = map
			end

			def add(e)

			end

			def <<(e)
				add(e)
			end
			
			def select
				raise('Method not implemented!')
			end
			
			def collect
				raise('Method not implemented!')
			end
			
			def find
				raise('Method not implemented!')
			end
			
			def each
				raise('Method not implemented!')
			end
		end
	end
end