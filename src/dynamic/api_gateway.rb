module ROM
	# Represents an entry point for the abstract API
	#
	# @see ROM::Resource
	# @example Generating a plan
	# 	# This example is using resources from the ROM::Resource dynamic example
	#
	# 	gtw = @itc.fetch(ApiGateway) # Fetch gateway from interconnect
	# 	plan = gtw.plan('api', 'v1', 'first', 'data') # Plan a call. 'api.v1.first.data(): String' in this case
	# 	plan.signature # => (): String
	# 	plan.run # => '1st'
	class ApiGateway
		include Component
		
		# Instantiates the {ROM::ApiGateway} class
		# @param [ROM::Interconnect] itc Interconnect that registers this instance
		def initialize(itc)
			@root = ResourceModule.new(:root)
			
			itc.lookup(Resource).each(&method(:index))
			itc.hook(Resource, &method(:index))
		end
		
		# Indexes a resource class
		# @param [ROM::Resource] rsc Resource to index
		def index(rsc)
			mod = rsc.class.path.split(Resource::PATH_SEPARATOR)
			rsc.class.actions.each do |act|
				@root.add(act, *mod)
			end
		end
		
		# Resolves a path
		# @param [Array<String>] path Path to resolve
		# @param [ROM::Resource, nil] rsc Resource to resolve the path relative to. If nil given, path is resolved with respect to root module
		# @return [ROM::ResourceAction] Resolved action; nil if not found
		def resolve(path, rsc = nil)
			if rsc == nil
				return @root.resolve(*path)
			else
				act = rsc[path.shift.to_s]
				if act == nil and rsc.default != nil
					act = WrappedResourceAction.new(rsc.default, path.shift.to_s)
				end
				return act
			end
		end
		
		# Generates an API call plan
		# @param [String] path Path to plan
		# @return [ROM::ApiGateway::ApiPlan] Plan of the API call
		def plan(*path)
			ret  = ApiPlan.new
			last = path.collect(&:to_s).reduce(@root) do |last, part|
				n = nil
				case last
					when ResourceModule
						n = last.resolve(part)
						raise("Unable to find object '#{part}' in module '#{last}'!") if n == nil
					when ResourceAction
						res = last.signature.return_type
						raise("Action '#{last}' returns final value! It cannot be called!") unless Types::Just[Resource].accepts(res)
						n = res.type[part]
						n = WrappedResourceAction.new(res.default, part) if n == nil and res.default != nil
						raise("Action '#{part}' not found in resource '#{res.name}'!") if n == nil
				end
				ret << n if n.is_a?(ResourceAction)
				next n
			end
			raise("Path doesn't specify an action!") if last.is_a?(ResourceModule)
			return ret
		end
		
		private :index
		
		# Represents a chain call of APIs
		class ApiPlan
			# Instantiates the {ROM::ApiGateway::ApiPlan} class
			def initialize
				@plan = []
			end
			
			# Gets the length of the call chain
			# @return [Integer] Length of the call chain
			def length
				@plan.length
			end
			
			# Gets the signature of call chain
			# @return [ROM::ActionSignature] Signature of call chain
			def signature
				f = @plan.first.signature
				args = {}
				f.arguments.each do |i|
					args[i] = f[i]
				end
				ActionSignature.new(@plan.last.signature.return_type, args)
			end
			
			# Executes the API call plan
			# @param [Object] args Arguments to invoke the API plan with
			# @return [Object, nil] Result of API call
			def run(*args)
				@plan.reduce(nil) do |last, act|
					if last == nil
						next act.invoke(*args)
					end
					next last.method(act.name).call
				end
			end
			
			# Adds a resource action call to the plan
			# @param [ROM::ResourceAction] act Action to add
			def <<(act)
				@plan << act
			end
			
			# Gets an action of call chain
			# @param [Integer] idx Order of action
			# @return [ROM::ResourceAction] Requested action; nil if not found
			def [](idx)
				@plan[idx]
			end
		end
		
		# Prepends arguments to an action call 
		class WrappedResourceAction < ResourceAction
			# Instantiates the {ROM::ApiGateway::WrappedResourceAction} class
			# @param [ROM::ResourceActoin] act Action to wrap
			# @param [Object] prepend Arguments to prepend to the call
			def initialize(act, *prepend)
				@act = act
				@pre = prepend
				super(@act.name, @act.resource, @act.signature, @act.attributes) do |*args|
					@act.invoke(*prepend, *args)
				end
			end
		end
		
		# Represents a single module of resources
		class ResourceModule
			# Gets the name of the module
			# @return [String] Name of the module
			def name
				@name
			end
			
			# Gets the submodules in this module
			# @return [Array<ROM::ApiGateway::ResourceModule>] Submodules of this module
			def modules
				@modules
			end
			
			# Gets the actions in this module
			# @return [Array<ROM::ResourceAction>] Actions of this module
			def actions
				@actions
			end
			
			# Instantiates the {ROM::ApiGateway::ResourceModule} class
			# @param [String] name Name of module
			# @param [ROM::ApiGateway::ResourceModule, nil] parent Parent module
			def initialize(name, parent = nil)
				@name    = name
				@parent  = parent
				@actions = {}
				@modules = {}
				@def     = nil
			end
			
			# Adds a resource action to the module
			# @param [ROM::ResourceAction] action Action to add
			# @param [String] mod Path of the action to add, relative to this module
			def add(action, *mod)
				if mod.length == 0
					raise("Action name '#{action.name}' from '#{self}' collides with sub-module of same name!") if @modules.has_key?(action.name)
					raise("Action name '#{action.name}' from '#{self}' collides with another action of same name!") if @actions.has_key?(action.name)
					if action.attribute?(DefaultAction)
						raise("Default action '#{d.name}' collides with '#{@def.name}' in '#{self}'!") unless @def == nil
						@def = action
					end
					@actions[action.name] = action
				else
					m = mod.shift
					raise("Module name '#{m}' from '#{self}' collides with action of same name!") if @actions.has_key?(m)
					m = (@modules.has_key?(m) ? @modules[m] : @modules[m] = ResourceModule.new(m, self))
					m.add(action, *mod)
				end
			end
			
			# Resolves a path relative to this module
			# @param [String] p Name within this module
			# @param [String] path Path relative to this module
			def resolve(p, *path)
				if @actions.has_key?(p)
					@actions[p]
				elsif @modules.has_key?(p)
					return @modules[p] if path.length == 0
					@modules[p].resolve(*path)
				elsif @def != nil
					WrappedResourceAction.new(@def, p)
				else
					return nil
				end
			end
			
			# Gets the name of this module as string
			# @return [String] Name of this module
			def to_s
				(@parent == nil ? @name.to_s : "#{@parent}#{Resource::PATH_SEPARATOR}#{@name}")
			end
		end
	end
end