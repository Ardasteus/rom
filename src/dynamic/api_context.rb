module ROM
	class ApiContext
		def hello(x)
			"Hello, #{x}!"
		end
		
		def context
			self
		end
		
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
		
		def method_missing(mtd, *args, &block)
			@__bind.send(mtd, *args, &block)
		end
	end
end