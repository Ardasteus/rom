module ROM
	module Authentication
		module Providers
			class TestProvider < AuthenticationProvider
				def initialize(itc)
					super(itc, "test", TestModel)
				end

				def open(conf)
					return Authentication::Authenticators::TestAuthenticator.new(conf.users)
				end

				class UserModel < Model
					property! :login, String
					property! :password, String
					property :first_name, String
					property :last_name, String
				end
				
				class TestModel < Model
					property! :users, Types::Array[UserModel]
				end
			end
		end
	end
end