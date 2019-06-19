# Created by Matyáš Pokorný on 2019-06-05.

module ROM
	module DB
		class Password < Model
			property! :login, Login, KeyAttribute[]
			property! :hash, String
		end
	end
end