module ROM
	# Provider of request specific information for API
	class ApiContext
		def hello(x)
			"Hello, #{x}!"
		end
		
		# Gets current API context
		# @return [ROM::ApiContext] Current API context
		def context
			self
		end
		
		def identity
			@id
		end
		
		def identity=(val)
			@id = val
		end
		
		def token
			@tok
		end
		
		def token=(val)
			@tok = val
		end
		
		
		def interconnect
			@itc
		end
		
		def initialize(itc = nil)
			@itc = itc
		end
		
		# Invokes a block using this context
		# @param [Binding] bind Block binding to use
		# @param [Object] args Arguments to invoke the block with
		# @param [Proc] block Block to invoke
		# @return [Object] Result of call
		def context_exec(bind, *args, &block)
			# So this... This must NEVER be shown to Šibrava
			
			old = @__bind
			@__bind = bind
			var = {}
			rem = []
			@__bind.instance_variables.each do |v|
				if instance_variable_defined?(v)
					var[v] = instance_variable_get(v)
				else
					rem << v
				end
				instance_variable_set(v, @__bind.instance_variable_get(v))
			end
			
			begin
				res = instance_exec(*args, &block)
			ensure
				@__bind = old
				
				rem.each(&method(:remove_instance_variable))
				var.each_pair(&method(:instance_variable_set))
			end
			
			res
		end
		
		# When method is not found in the context class, this method calls the method on current binding
		# @param [Symbol] mtd Name of method
		# @param [Object] args Arguments of method call
		# @param [Proc] block Block of method call
		# @return [Object] Result of call
		def method_missing(mtd, *args, &block)
			@__bind.send(mtd, *args, &block)
		end
	end
end