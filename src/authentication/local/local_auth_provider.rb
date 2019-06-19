# Created by Matyáš Pokorný on 2019-06-05.

module ROM
	module Authentication
		module Providers
			class LocalAuthenticationProvider < AuthenticationProvider
				DRIVER = 'local'
				
				def initialize(itc)
					super(itc, DRIVER, LocalConfig)
				end
				
				def open(name, conf)
					Authentication::Authenticators::LocalAuthenticator.new(@itc.fetch(DbServer), name, conf)
				end
				
				class LocalConfig < Model
					property :cost, Integer, 12
				end
			end
		end
	end
end