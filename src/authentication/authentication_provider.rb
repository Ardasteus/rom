module ROM
	module Authentication
		module Providers
			class AuthenticationProvider
				include Component

				def config_model
					@mod
				end

				def initiliaze(itc, name, mod)
					@itc = itc
					@name = name
					@mod = mod
				end

				def open(conf)
					
				end

				def is_name?(name)
					name == @name
				end
			end
		end
	end
end
