module ROM
	module Authentication
		class TokenFactory
			include ROM::Component
			
			def name
				@name
			end
			
			def config_model
				@conf
			end
			
			def initialize(itc, nm, conf)
				@itc = itc
				@name = nm
				@conf = conf
			end
			
			def issue_token(user, login, stamp)
			
			end
			
			def config(conf)
			
			end
			
			def to_string(token)
			end
			
			def from_string(string)
			end
		end
	end
end