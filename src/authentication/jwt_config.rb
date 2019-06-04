# Created by Matyáš Pokorný on 2019-06-04.

module ROM
	module Authentication
		class JwtConfig < Model
			property :rsa_size, Integer, 2048
		end
	end
end