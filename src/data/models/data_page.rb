# Created by Matyáš Pokorný on 2019-06-10.

module ROM
	class DataPage < Model
		property! :items, Types::Array[Model]
		property! :total, Integer
	end
end