module ROM
	module Authentication
			class AuthenticationProvider
				include Component
				modifiers :abstract

				def config_model
					@mod
				end

				def initialize(itc, name, mod)
					@itc = itc
					@name = name
					@mod = mod
				end

				def open(name, conf)
					
				end

				def is_name?(name)
					name == @name
				end
			end
		end
	end
