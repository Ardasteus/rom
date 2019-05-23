module ROM
	module Authentication
		module Providers
		class AuthenticationProvider
			include Component
				def initiliaze(itc)
					@itc = itc
					@name = "default"
				end

				def open(conf)
					
				end
			end
		end
	end
end
