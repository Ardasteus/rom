# Created by Matyáš Pokorný on 2019-05-18.

module ROM
	# Base class of a DB collection of entities
	# @abstract
	class DbCollection
		# Filters only entities that match given expression
		# @yield [tab] Filter builder function
		# @yieldparam [Object] tab Double of a table
		# @yieldreturn [ROM::Queries::QueryExpression] Filtering expression
		def select
			raise('Method not implemented!')
		end
		
		# Reduces each entity into a single scalar value
		# @yield [tab] Expression builder function
		# @yieldparam [Object] tab Double of a table
		# @yieldreturn [ROM::Queries::QueryExpression] Reducing expression
		def collect
			raise('Method not implemented!')
		end
		
		# @overload find()
		# 	Finds a single entity that matched given expression
		# 	@yield [tab] Matcher builder function
		# 	@yieldparam [Object] tab Double of a table
		# 	@yieldreturn [ROM::Queries::QueryExpression] Matching expression
		# 	@return [Entity, nil] Found entity; nil otherwise
		# @overload find(*keys)
		# 	Finds a single entity of provided keys (in order of appearance in model)
		# 	@param [Object, nil] keys Key values
		# 	@return [Entity, nil] Found entity; nil otherwise
		# @overload find(**named_keys)
		# 	Finds a single entity of provided keys
		# 	@param [Object, nil] named_keys Key values
		# 	@return [Entity, nil] Found entity; nil otherwise
		def find(*keys, **named_keys)
			raise('Method not implemented!')
		end
		
		# Sorts (in ascending order) resulting set based on given expression
		# @yield [tab] Expression builder function
		# @yieldparam [Object] tab Double of a table
		# @yieldreturn [ROM::Queries::QueryExpression] Sorting value expression
		def sort_by
			raise('Method not implemented!')
		end
		
		# Sorts (in descending order) resulting set based on given expression
		# @yield [tab] Expression builder function
		# @yieldparam [Object] tab Double of a table
		# @yieldreturn [ROM::Queries::QueryExpression] Sorting value expression
		def sort_by_desc
			raise('Method not implemented!')
		end
		
		# Enumerates all entities
		# @yield [e] Block to execute for each entity
		# @yieldparam [Entity] e Fetched entity
		def each
			raise('Method not implemented!')
		end
	end
end