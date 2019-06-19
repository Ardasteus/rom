# Created by Matyáš Pokorný on 2019-06-08.

module ROM
	class AuthorizeAttribute < Attribute
		def judgements
			@jdg
		end
		
		def initialize(*jdg)
			@jdg = jdg
		end
	end
end