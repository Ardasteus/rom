module ROM
	module Authentication < AuthenticationProvider
		class LDAPProvider
			def initiliaze(itc)
				@itc = itc
				@name = "ldap"
			end

			def open(conf)
			end
		end
	end
end