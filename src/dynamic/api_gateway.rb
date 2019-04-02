module ROM
	class ApiGateway
		include Component
		
		def initialize(itc)
			@root = ResourceModule.new(:root)
			
			itc.lookup(Resource).each(&method(:index))
			itc.hook(Resource, &method(:index))
		end
		
		def index(rsc)
			mod = rsc.class.path.split(Resource::PATH_SEPARATOR)
			rsc.class.actions.each do |act|
				@root.add(act, *mod)
			end
		end
		
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
		
		def plan(*path)
			ret  = ApiPlan.new
			last = path.reduce(@root) do |last, part|
				n = nil
				case last
					when ResourceModule
						n = last.resolve(part)
						raise("Unable to find object '#{part}' in module '#{last.to_s}'!") if n == nil
					when ResourceAction
						res = last.signature.return_type
						raise("Action '#{last.to_s}' returns final value! It cannot be called!") unless Types::Just[Resource].accepts(res)
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
		
		class ApiPlan
			def initialize
				@plan = []
			end
			
			def run(*args)
				@plan.reduce(nil) do |last, act|
					if last == nil
						next act.invoke(*args)
					end
					next last.method(act.name).call
				end
			end
			
			def <<(act)
				@plan << act
			end
		end
		
		class WrappedResourceAction < ResourceAction
			def initialize(act, *prepend)
				@act = act
				@pre = prepend
				super(@act.name, @act.resource, @act.signature, @act.attributes) do |*args|
					@act.invoke(*prepend, *args)
				end
			end
		end
		
		class ResourceModule
			def name
				@name
			end
			
			def modules
				@modules
			end
			
			def actions
				@actions
			end
			
			def initialize(name, parent = nil)
				@name    = name
				@parent  = parent
				@actions = {}
				@modules = {}
				@def     = nil
			end
			
			def add(action, *mod)
				if mod.length == 0
					raise("Action name '#{action.name}' from '#{self.to_s}' collides with sub-module of same name!") if @modules.has_key?(action.name)
					raise("Action name '#{action.name}' from '#{self.to_s}' collides with another action of same name!") if @actions.has_key?(action.name)
					if action.attribute?(DefaultAction)
						raise("Default action '#{d.name}' collides with '#{@def.name}' in '#{self.to_s}'!") unless @def == nil
						@def = action
					end
					@actions[action.name] = action
				else
					m = mod.shift
					raise("Module name '#{m}' from '#{self.to_s}' collides with action of same name!") if @actions.has_key?(m)
					m = (@modules.has_key?(m) ? @modules[m] : @modules[m] = ResourceModule.new(m, self))
					m.add(action, *mod)
				end
			end
			
			def resolve(p, *path)
				if @actions.has_key?(p)
					@actions[p]
				elsif @modules.has_key?(p)
					return @modules[p] if path.length == 0
					@modules[p].resolve(*path)
				else
					WrappedResourceAction.new(@def, p)
				end
			end
			
			def to_s
				(@parent == nil ? @name.to_s : "#{@parent.to_s}#{Resource::PATH_SEPARATOR}#{@name.to_s}")
			end
		end
	end
end