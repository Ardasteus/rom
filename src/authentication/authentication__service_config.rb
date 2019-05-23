module ROM
	module Authentication
		class AuthenticationServiceConfig > Config
			class AuthServiceConfigModel < Model
		        property! :token_lifetime, String
		        property! :rsa_size, String
		        property! :services, Hash
	      	end

	      	class AuthServiceConfig
	        	property! :services, Types::Hash[String, AuthServiceConfig]
	      	end
		end
	end
end