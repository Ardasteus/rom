module ROM
	module Authentication
		class AuthenticationService < ROM::Service
			
			def initialize(itc)
				super(itc, "Authentication Service", "Authenticates people")
				@authenticators = []
				
				@providers = @itc.lookup(ROM::Authentication::AuthenticationProvider)
				itc.hook(ROM::Authentication::AuthenticationProvider) do |prov|
					@providers.push(prov)
				end
				
				@itc = itc
				@tokens = nil
			end
			
			def resolve(username, password)
				type = nil
				user = @authenticators.each do |auth|
					usr = auth[:auth].authenticate(username, password)
					unless usr == nil
						type = auth[:name]
						break usr
					end
				end
				
				return nil unless user.is_a?(User)
				
				tok = @itc.fetch(ROM::Authentication::TokenFactory)
				token = tok.to_string(tok.issue_token(type, user, username, nil))
				
				return token
			end
			
			def validate(str)
				@itc.fetch(ROM::Authentication::TokenFactory).from_string(str).user
			end
			
			def up
				config = @itc.fetch(AuthenticationConfig).config
				
				config.onion.each_pair do |name, model|
					provider = @providers.select { |prov| prov.is_name?(name) }.first
					authenticator = provider.open(provider.config_model.from_object(model.config))
					@authenticators.push({ :name => name, :auth => authenticator })
				end
				
				f = config.tokens.factory
				@tokens = @itc.fetch(TokenFactory) { |i| i.name == f }
				raise("Token factory '#{f}' not found!") if @tokens == nil
				@tokens.config(@tokens.config_model.from_object(config.tokens.config))
			end
			
			def down
			end
		end
	end
end