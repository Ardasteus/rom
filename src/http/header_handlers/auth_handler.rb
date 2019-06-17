# Created by Matyáš Pokorný on 2019-06-04.

module ROM
	module HTTP
		module HeaderHandlers
			class AuthenticationHandler < HTTPHeaderHandler
				SCHEME = 'Bearer'
				
				def initialize(itc)
					super(itc, :authorization)
					@auth = itc.pin(Authentication::AuthenticationService)
				end
				
				def handle(hdr, value, ctx)
					mtd, ctx.token = value.split(' ')
					raise(UnauthenticatedException.new) if mtd != SCHEME
					begin
						id = @auth.validate(ctx.token)
					rescue
						raise(UnauthenticatedException.new)
					end
					raise(UnauthenticatedException.new) if id == nil
					
					ctx.identity = id
				end
			end
		end
	end
end