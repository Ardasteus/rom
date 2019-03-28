module ROM
	class Resource
		PATH_SEPARATOR = '.'

		def self.actions
			@act.values
		end
		
		def self.path
			@path
		end
		
		def self.default
			@def = nil
		end
		
		def self.[](name)
			@act[name.to_s]
		end
		
		def self.prepare_resource
			@act = {}
			@path = ''
			@def = nil
		end

		def self.inherited(klass)
			klass.prepare_resource
		end

		def self.namespace(*path)
			raise('Path parts cannot contain path separator!') if path.include?(PATH_SEPARATOR)
			@path = path.collect(&:to_s).join(PATH_SEPARATOR)
		end

		def self.action(name, ret, *att, **sig, &block)
			raise('Action with same name already defined!') if @act.has_key?(name.to_s)
			raise('Action name cannot contain path separator!') if name.to_s.include?(PATH_SEPARATOR)
			act = ResourceAction.new(name.to_s, ActionSignature.new(ret, sig), att, &block)
			if att.any? { |i| i.is_a?(DefaultAction) }
				raise("Default action '#{act.name}' collides with '#{@def.name}'!") unless @def == nil
				@def = act
			end
			
			@act[name.to_s] = act
			
			define_method(name.to_sym, &block)
		end
	end
	
	class StaticResource < Resource
		include Component
		
		def initialize(itc)
		
		end
	end

	class ResourceAction
		def name
			@name
		end

		def signature
			@sig
		end

		def attributes
			@att
		end

		def invoke(*args)
			@action.call(*args)
		end

		def initialize(nm, sig, att, &block)
			@name = nm
			@action = block
			@att = att
			@sig = sig
		end
		
		def attribute(klass)
			@att.each { |i| return i if i.is_a?(klass) }
			end
		
		def attribute?(klass)
			@att.any? { |i| i.is_a?(klass) }
		end
	end

	class ActionSignature
		def return_type
			@ret
		end

		def arguments
			@sig.keys
		end

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
						@sig[name] = { :type => v, :required => req, :default => nil, :order => order }
					when Class
						@sig[name] = { :type => Types::Type.to_t(v), :required => req, :default => nil, :order => order }
					when Hash
						raise("Argument '#{name}' doesn't specify type!") unless v.has_key?(:type)
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

		def [](arg)
			case arg
				when Symbol
					return @sig[arg]
				when Integer
					@sig.each { |i| return i if i[:order] == arg }
					return nil
				else
					return nil
			end
		end
	end
	
	class DefaultAction < Attribute
	
	end
end