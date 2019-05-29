module ROM
	module Authentication
		module Providers
			class LDAPProvider < AuthenticationProvider
				def initialize(itc)
					super(itc, "ldap", LDAPModel)
				end

				def open(conf)
					return LDAPAuthenticator.new(conf.host, conf.port)
				end

				class LDAPModel < Model
					property! :host, String
					property! :port, Integer, 389
				end
			end
		end
	end
end