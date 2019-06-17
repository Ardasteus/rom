module ROM
	module Authentication
		module Authenticators
			class ListAuthenticator < Authenticator
				def initialize(users)
					@users = users
				end
				
				def authenticate(username, password)
					@users.each do |user|
						if user.login == username
							break if user.password != password
							fn = ''
							fn += user.first_name if user.first_name != nil
							if user.last_name != nil
								fn += ' ' if fn.length > 0
								fn += user.last_name
							end
							fn = user.login if fn.length == 0
							return User.new(fn, (user.first_name or fn), user.last_name)
						end
					end
					
					nil
				end
			end
		end
	end
end