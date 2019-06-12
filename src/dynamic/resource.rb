module ROM
	# Represents a resource
	#
	# @example Static API
	# 	module ROM
	# 		module API
	# 			class StatusApi < StaticResource
	# 				# Static resource classes are registered at the interconnect, thus instantiated once
	# 				
	# 				path :api, :v1
	# 				
	# 				# Endpoint available as 'api.v1.status(): String'
	# 				action :status, String do 
	# 					return 'Server is running...'
	# 				end
	# 			end
	# 		end
	# 	end
	# @example Call-chain API
	# 	module ROM
	# 		module API
	# 			class Data < Resource
	# 				# Dynamic resources are returned by static resources
	# 				
	# 				def initialize(data)
	# 					@data = data
	# 				end
	# 				
	# 				action :data, String do
	# 					return @data
	# 				end
	# 			end
	# 			
	# 			class DataApi < StaticResource
	# 				path :api, :v1
	#
	# 				def initialize(itc)
	# 					super(itc)
	# 					@hash = { 'first' => Data.new('1st'), 'last' => Data.new('2nd') }
	# 				end
	# 				
	# 				# Endpoint marked as default will be called when action on the resource cannot be found
	# 				# The requested name is prepended as a string argument
	# 				action :default, Data, DefaultAction[] do |name|
	# 					return @hash[name]
	# 				end
	# 				
	# 				# Call 'api.v1.first.data(): String' is available and it will return '1st'
	# 				# Call 'api.v1.second.data(): String' is available and it will return '2nd'
	# 			end
	# 		end
	# 	end
	class Resource
		# Separator character of modules and actions
		PATH_SEPARATOR = '.'
		# Gets the union type that is allowed as arguments and return values
		ALLOWED_TYPE = Types::Maybe[Types::Union[Numeric, String, Model, Resource, Types::Boolean[], IO, Types::Void]]
		
		# Gets actions declared within the resource
		# @return [Array<ROM::ResourceAction>] Actions declared within the resource
		def self.actions
			@act.values
		end
		
		# Gets the path of this resource
		# @return [Array<String>] Path of this resource
		def self.path
			@path
		end
		
		# Gets the default resource action
		# @return [ROM::ResourceAction, nil] Default resource action; nil if none
		def self.default
			@def
		end
		
		# Gets an action in this resource
		# @param [String, Symbol] name Name of the action to get
		# @return [ROM::ResourceAction, nil] Action of given name; nil of not found
		def self.[](name)
			@act[name.to_s]
		end
		
		def close
		
		end
		
		# Prepares the resource class
		# @return [void]
		def self.prepare_resource
			@act = {}
			@path = ''
			@def = nil
		end
		
		# Invoked when the class is inherited
		# @param [Class] klass Inheriting class
		def self.inherited(klass)
			klass.prepare_resource
		end
		
		# Sets the path of the resource
		# @param [String] path Path of the resource
		def self.namespace(*path)
			raise('Path parts cannot contain path separator!') if path.include?(PATH_SEPARATOR)
			@path = path.collect(&:to_s).join(PATH_SEPARATOR)
		end
		
		# Defines an action
		# @param [String, Symbol] name Name of the action
		# @param [Class, ROM::Types::Type] ret Return type of the action
		# @param [ROM::Attribute] att Metadata attributes of the action
		# @param [Hash{Symbol => [Class, ROM::Types::Type, Hash]}] sig Signature of the action
		# @param [Proc] block Block of action
		# @yield [] Block of action
		# @return [void]
		def self.action(name, ret, *att, **sig, &block)
			raise('Action with same name already defined!') if @act.has_key?(name.to_s)
			raise('Action name cannot contain path separator!') if name.to_s.include?(PATH_SEPARATOR)
			raise('Action may only return models, primitives or another resources!') unless ALLOWED_TYPE.accepts(ret)
			raise('Action block not given!') unless block_given?
			act = ResourceAction.new(name.to_s, self, ActionSignature.new(ret, sig), att, &block)
			if att.any? { |i| i.is_a?(DefaultAction) }
				raise("Default action '#{act.name}' collides with '#{@def.name}'!") unless @def == nil
				@def = act
			end
			
			@act[name.to_s] = act
			
			define_method(name.to_sym, &block)
		end
	end
	
	# Represents a resource which can be statically registered
	# @see ROM::Resource
	class StaticResource < Resource
		include Component
		modifiers :abstract
		
		# Instantiates the {ROM::StaticResource} class
		# @param [ROM::Interconnect] itc Interconnect which register the instance
		def initialize(itc)
		
		end
	end
	
	# Represents an API action
	class ResourceAction
		# Gets the name of action
		# @return [Symbol] Name of action
		def name
			@name
		end
		
		# Gets the signature of the action
		# @return [ROM::ActionSignature] Signature of the action
		def signature
			@sig
		end
		
		# Gets the metadata attributes of the action
		# @return [Array<ROM::Attribute>] Attributes of the action
		def attributes
			@att
		end
		
		# Gets the resource to which this action is bound
		# @return [ROM::Resource] Parent resource
		def parent
			@parent
		end
		
		# Invokes the action with given arguments
		# @param [Object, nil] args Arguments to invoke the action with
		# @return [Object, nil] Result of the action
		def invoke(ctx, inst = nil, *args)
			ctx.context_exec((inst or @action.binding.eval('self')), *args, &@action)
		end
		
		# Instantiates the {ROM::ResourceAction} class
		# @param [Symbol] nm Name of action
		# @param [Class] parent Parent resource
		# @param [ROM::ActionSignature] sig Signature of the action
		# @param [Array<ROM::Attribute>] att Metadata attributes of the action
		# @yield [] Block of the action
		def initialize(nm, parent, sig, att, &block)
			@name = nm
			@parent = parent
			@action = block
			@att = att
			@sig = sig
		end
		
		def bind(res)
			BoundResourceAction.new(@name, res, @sig, @att, &@action)
		end
		
		# Gets a metadata attribute of the given class
		# @param [Class] klass Class of the attribute to fetch
		# @return [ROM::Attribute, nil] First attribute of the given type; nil of no such attribute could be found
		def attribute(klass)
			@att.each { |i| return i if i.is_a?(klass) }
		end
		
		# Gets whether the action has a metadata attribute of the given type
		# @param [Class] klass Class of the attribute to look for
		# @return [Bool] True if attribute of given type is found; false otherwise
		def attribute?(klass)
			@att.find { |i| i.is_a?(klass) } != nil
		end
		
		# Gets the path and signature of the action
		# @return [String] Path and signature of the action
		def to_s
			p = @res.path
			"#{(p == '' ? '' : "#{p}.")}#{@name}#{@sig}"
		end
	end
	
	class BoundResourceAction < ResourceAction
		def initialize(nm, res, sig, att, &block)
			super(nm, res.class, sig, att, &block)
			@res = res
		end
		
		# Invokes the action with given arguments
		# @param [Object, nil] args Arguments to invoke the action with
		# @return [Object, nil] Result of the action
		def invoke(ctx, inst = nil, *args)
			ctx.context_exec((inst or @res), *args, &@action)
		end
	end
	
	# Represents the signature of the action
	class ActionSignature
		# Gets the type which the action returns
		# @return [ROM::Types::Type] Type which the action returns
		def return_type
			@ret
		end
		
		# Gets the specification of the action arguments
		# @return [Hash{Symbol => Hash{Symbol => Object}}] Specification of the action arguments
		def arguments
			@sig.keys
		end
		
		# Instantiates the {ROM::ActionSignature} class
		# @param [ROM::Types::Type] ret Return type of the action
		# @param [Hash{Symbol => Hash}] sig Specification of the action arguments
		def initialize(ret, sig)
			@sig = {}
			@ret = Types::Type.to_t(ret)
			
			order = 0
			sig.each_pair do |k, v|
				raise("Expecting argument name #{k.inspect} to be a symbol!") unless k.is_a?(Symbol)
				
				k = k.to_s
				req = k.end_with?('!')
				name = (req ? k[0..k.length - 2] : k).to_sym
				case v
					when Types::Type
						@sig[name] = { :name => name, :type => v, :required => req, :default => nil, :order => order }
					when Class
						@sig[name] = { :name => name, :type => Types::Type.to_t(v), :required => req, :default => nil, :order => order }
					when Hash
						raise("Argument '#{name}' doesn't specify type!") unless v.has_key?(:type)
						v[:name] = name
						v[:required] = req unless v.has_key?(:required)
						v[:default] = nil unless v.has_key?(:default)
						v[:order] = order unless v.has_key?(:order)
						@sig[name] = v
					else
						raise("Argument signature for '#{name}' expects to be either a #{Class.name} or #{Hash.name}!")
				end
				order += 1
			end
		end
		
		# Gets the string representation of the signature
		# @return [String] String representation fo the signature
		def to_s
			"(#{@sig.keys.collect { |k| "#{k}: #{self[k][:type]}#{(self[k][:required] ? '' : " = #{self[k][:default].inspect}")}" }.join(', ')}): #{@ret}"
		end
		
		def each
			@sig.values.sort_by { |i| i[:order] }.each { |i| yield(i) }
		end
		
		# Checks whether supplied arguments may be used to invoke this action
		# @param [Object, nil] args Arguments to test
		# @return [Boolean] True if action may be called; false otherwise
		def accepts(*args)
			req = @sig.count { |arg| arg[1][:required] }
			return args.length >= req
		end
		
		# @overload [](arg)
		# 	Gets specification of an argument based on its name
		# 	@param [Symbol] arg Name of the argument
		# 	@return [Hash, nil] Specification of the given argument; nil if not found
		# @overload [](arg)
		# 	Gets specification of an argument based on its order
		# 	@param [Integer] arg Order of the argument
		# 	@return [Hash, nil] Specification of the given argument; nil if not found
		def [](arg)
			case arg
				when Symbol
					return @sig[arg]
				when Integer
					@sig.each_pair { |key, val| return val if val[:order] == arg }
					return nil
				else
					return nil
			end
		end
	end
	
	# Marks resource actions as defaults
	class DefaultAction < Attribute
	
	end
end