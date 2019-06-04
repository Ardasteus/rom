# Created by Matyáš Pokorný on 2019-05-27.

module ROM
	# Component of a DB context
	class DbHook
		include Component
		
		# Gets the name of a context
		# @return [String] Name of context
		def name
			@name
		end
		
		# Gets the context class
		# @return [Class] Context class
		def context
			@ctx
		end
		
		# Instantiates the {ROM::DbHook} class
		# @param [ROM::Interconnect] itc Registering interconnect
		# @param [String] nm Name of context
		# @param [Class] ctx Class of context
		def initialize(itc, nm, ctx)
			@name = nm
			@ctx = ctx
		end
	end
end