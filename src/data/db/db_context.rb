module ROM
	class DbContext
		def initialize(db, sch)
			@db = db
			@sch = sch
			@lazy = {}

			self.class.tables.each do |tab|
				t = sch.tables.find { |i| i.table == tab }
				col = TableCollection.new(@db, t, EntityMapper.new(t, {}))
				self.class.send(:define_method, tab.name.to_sym) do
					col
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
				raise('Method not implemented!')
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
				qry = @db.driver.select(@tab)
				@db.query(qry).each do |row|
					yield(@map.map(row))
				end
			end
		end
	end
end