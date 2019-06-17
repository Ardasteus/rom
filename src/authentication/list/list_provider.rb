module ROM
	module Authentication
		module Providers
			class ListProvider < AuthenticationProvider
				def initialize(itc)
					super(itc, 'list', ConfigModel)
				end

				def open(name, conf)
					Authentication::Authenticators::ListAuthenticator.new(conf.users)
				end

				class UserModel < Model
					property! :login, String
					property! :password, String
					property :first_name, String
					property :last_name, String
				end
				
				class ConfigModel < Model
					property! :users, Types::Array[UserModel]
				end
			end
		end
	end
end