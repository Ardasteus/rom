# Created by Matyáš Pokorný on 2019-03-17.

module ROM
	# Connects components together
	class Interconnect
		def generation
			@gen
		end
		
		# Instantiates the {ROM::Interconnect} class
		def initialize(**opt)
			@log   = BufferLogger.new
			@reg   = Set.new
			@hooks = []
			@opt = opt
			@opt[:log] = true
			@gen = 0
			
			hook(LogServer) do |log|
				if @log.is_a?(BufferLogger)
					@log.trace('Bound log for interconnect! Flushing buffer logger...') if opt? :verbose
					@log.flush(log)
					@log = log
				end
			end
		end
		
		# Sets up a hook which is called whenever a new component of a given type is registered
		# @param [Class] type Type of component to set the hook for
		# @yield [item] Block of the hook
		# @yieldparam [Object] item The registered item
		def hook(type, &block)
			@log.trace("Setting interconnect hook for '#{type.name}'...") if opt? :hooks
			@hooks << { :type => type, :hook => block }
		end
		
		def view(type, &filter)
			View.new(self, type, filter)
		end
		
		def pin(type, &filter)
			Pin.new(self, type, filter)
		end
		
		# Loads all components in a module
		# @param [Module] mod Module to scan
		# @return [void]
		def load(mod)
			mod.constants.collect { |i| mod.const_get(i) }.select { |i| i.is_a?(Module) }.each do |com|
				register(com) if com.is_a?(Class) and com.include?(Component)
				load(com) if com.class == Module
			end
		end
		
		# Registers a components class
		# @param [Class] com Component class
		# @return [void]
		def register(com)
			@log.trace("Importing '#{com.name}'...") if opt? :log
			hooks = @hooks.select { |i| com <= i[:type] }
			com.register(self).each do |i|
				@reg << i
				hooks.each { |h| @log.trace('Invoking hook...'); h[:hook].call(i) }
				@gen += 1
			end
		end
		
		# @overload lookup(type)
		# 	Looks up all components of specified base type
		# 	@param [Class] type Type to lookup
		# 	@return [Array<Object>] All components of the given type
		# @overload lookup(type)
		# 	Looks up all components of specified base type and filters them using a function
		# 	@param [Class] type Type to lookup
		# 	@yield [item] Filter function
		# 	@yieldparam [Object] item Component to match against the filter function
		# 	@yieldreturn [Bool] True if item matches the function; false otherwise
		# 	@return [Array<Object>] All components of the given type which match the given filter function
		def lookup(type)
			@reg.select { |i| i.is_a?(type) and (not block_given? or yield(i)) }
		end
		
		# @overload fetch(type)
		# 	Gets the first occurrence of a component of the given type
		# 	@param [Class] type Type to lookup
		# 	@return [Object, nil] First occurrence of a component of the given type; nil if no such component could be found
		# @overload fetch(type)
		# 	Gets the first occurrence of a component of the given type which also matches the given filter function
		# 	@param [Class] type Type to lookup
		# 	@yield [item] Filter function
		# 	@yieldparam [Object] item Component to match against the filter function
		# 	@yieldreturn [Bool] True if item matches the function; false otherwise
		# 	@return [Object, nil] First occurrence of a component of the given type which also match the given filter function; nil if no such component could be found
		def fetch(type)
			@reg.each do |i|
				return i if i.is_a?(type) and (not block_given? or yield(i))
			end
			return nil
		end

		def opt?(sym)
			return (@opt[sym] != nil and @opt[sym])
		end

		private :opt?
		
		class View
			include Enumerable
			
			def initialize(itc, type, filter)
				@itc = itc
				@type = type
				@filter = filter
				@view = nil
				@last = nil
			end
			
			def reload
				@view = @itc.lookup(@type, &@filter)
				@last = @itc.generation
			end
			
			def each
				reload if (@last == nil or @last < @itc.generation)
				@view.each { |i| yield i }
			end
		end
		
		class Pin
			def item
				reload if (@last == nil or @last < @itc.generation)
				
				@item
			end
			
			def initialize(itc, type, filter)
				@itc = itc
				@type = type
				@filter = filter
				@item = nil
				@last = nil
			end
			
			def reload
				@item = @itc.fetch(@type, &@filter)
				@last = @itc.generation
			end
			
			def method_missing(name, *args, &block)
				item.send(name, *args, &block)
			end
		end
	end
end