# Created by Matyáš Pokorný on 2019-05-12.

module ROM
	class DbSchema
		def tables
			@tab
		end
		
		def references
			@ref
		end

		def initialize
			@tab = []
			@ref = []
		end

		def table(nm, tab)
			raise("Table with name '#{nm}' was already added!") if @tab.any? { |i| i.name == nm }
			tab = DbTable.new(nm, tab)
			@tab << tab
			
			tab
		end

		def [](key)
			@tab.find { |tab| tab.name.to_s == key.to_s }
		end

		def reference(name, src, dest, upd = :cascade, dlt = :cascade)
			raise("Reference for column '#{src.name}' already set!") if @ref.any? { |i| i.source == src }
			raise("Source table '#{src.table.name}' is not part of the schema!") unless @tab.include?(src.table)
			raise("Target table '#{dest.table.name}' is not part of the schema!") unless @tab.include?(dest.table)
			ref = DbReference.new(name, src, dest, upd, dlt)
			src.reference = ref
			@ref << ref
		end
	end
end