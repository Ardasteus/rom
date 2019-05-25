# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	class Media < Model
		property :id, Integer
		property! :name, String
		property! :type, TypeMedia
		property! :size, Integer
	end
end