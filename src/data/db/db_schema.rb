# Created by Matyáš Pokorný on 2019-05-12.

module ROM
	# Represents an SQL schema
	class DbSchema
		# Gets tables of the schema
		# @return [Array<ROM::DbTable>] Schema tables
		def tables
			@tab
		end
		
		# Gets references of the schema
		# @return [Array<ROM::DbReference>] Schema references
		def references
			@ref
		end

		# Instantiates the {ROM::DbSchema} class
		def initialize
			@tab = []
			@ref = []
		end

		# Creates a new table
		# @param [String] nm Name of table
		# @param [ROM::DbContext::Table] tab Table context mapping
		# @return [ROM::DbTable] Created table
		def table(nm, tab)
			raise("Table with name '#{nm}' was already added!") if @tab.any? { |i| i.name == nm }
			tab = DbTable.new(nm, tab)
			@tab << tab
			
			tab
		end

		# Gets table by name
		# @param [String, Symbol] key Name of table to find
		# @return [ROM::DbTable, nil] Found table; nil otherwise
		def [](key)
			@tab.find { |tab| tab.name.to_s == key.to_s }
		end

		# Creates a new reference
		# @param [String] name Name of reference
		# @param [ROM::DbColumn] src Referencing column
		# @param [ROM::DbColumn] dest Referenced column
		# @param [Symbol] upd Reference update strategy (:cascade, :null, :fail, :default)
		# @param [Symbol] dlt Reference delete strategy (:cascade, :null, :fail, :default)
		# @return [ROM::DbReference] Created reference
		def reference(name, src, dest, upd = :cascade, dlt = :cascade)
			raise("Reference for column '#{src.name}' already set!") if @ref.any? { |i| i.from == src }
			raise("Source table '#{src.table.name}' is not part of the schema!") unless @tab.include?(src.table)
			raise("Target table '#{dest.table.name}' is not part of the schema!") unless @tab.include?(dest.table)
			ref = DbReference.new(name, src, dest, upd, dlt)
			src.reference = ref
			@ref << ref
		end
	end
end