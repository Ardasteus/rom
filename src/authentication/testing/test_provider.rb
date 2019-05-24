module ROM
	module Authentication
		module Providers
			class LDAPProvider < AuthenticationProvider
				def initiliaze(itc)
					super(itc, "test", TestModel)
				end

				def open(conf)
					return TestAuthenticator.new(conf.user, conf.password)
				end

				class TestModel < Model
					property! :user, String, "user:"
					property! :password, String, "password:"
				end
			end
		end
	end
end