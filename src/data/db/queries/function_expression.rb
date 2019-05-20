module ROM
	module Queries
		class FunctionExpression < QueryExpression
			def function
				@f
			end
			
			def type
				@type
			end

			def arguments
				@args
			end

			def initialize(f, *args)
				@f = f
				@args = args
				@type = f.type(*args)
			end

			class Function
				def name
					@name
				end

				def arguments
					@args
				end

				def type(*args)
					Types::Type.to_t(@type.call(*args))
				end

				def initialize(nm, &block)
					@name = nm
					@type = block
				end
			end

			COUNT = Function.new('count') { Integer }
		end
	end
end