module ROM
	module Authentication
		module Providers
			class TestProvider < AuthenticationProvider
				def initialize(itc)
					super(itc, "test", TestModel)
				end

				def open(conf)
					return Authentication::Authenticators::TestAuthenticator.new(conf.user, conf.password)
				end

				class TestModel < Model
					property! :user, String
					property! :password, String
				end
			end
		end
	end
end