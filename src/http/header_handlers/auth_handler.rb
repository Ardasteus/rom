# Created by Matyáš Pokorný on 2019-06-04.

module ROM
	module HTTP
		module HeaderHandlers
			class AuthenticationHandler < HTTPHeaderHandler
				def initialize(itc)
					super(itc, :authorization)
					@auth = itc.pin(Authentication::AuthenticationService)
				end
				
				def handle(hdr, value, ctx)
					mtd, token = value.split(' ')
					raise(UnauthenticatedException.new) if mtd != 'Bearer'
					begin
						user = @auth.validate(token)
					rescue
						raise(UnauthenticatedException.new)
					end
					raise(UnauthenticatedException.new) if user == nil
					
					ctx.user = user
				end
			end
		end
	end
end