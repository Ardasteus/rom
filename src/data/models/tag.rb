# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	module DB
		# E-Mail tag
		class Tag < Model
			property :id, Integer
			property! :name, String, IndexAttribute[]
			property :color, Integer, 0xFFFFFFFF
			property! :user, User, SuffixAttribute['owner']
		end
	end
end