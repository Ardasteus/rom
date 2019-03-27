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
				act = rsc.class[path.shift.to_s]
				if act == nil and rsc.class.default != nil
					act = WrappedResourceAction.new(rsc.class.default, path.shift.to_s)
				end
				return act
			end
		end
		
		private :index
		
		class WrappedResourceAction < ResourceAction
			def initialize(act, *prepend)
				@act = act
				@pre = prepend
				super(@act.name, @act.signature, @act.attributes) do |*args|
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
			
			def resolve(*path)
				p = path.shift.to_s
				if @actions.has_key?(p)
					@actions[p]
				elsif @modules.has_key?(p)
					@modules[p].resolve(*path)
				else
					@def
				end
			end
			
			def to_s
				(@parent == nil ? @name.to_s : "#{@parent.to_s}#{Resource::PATH_SEPARATOR}#{@name.to_s}")
			end
		end
	end
end