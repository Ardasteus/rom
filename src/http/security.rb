# Created by Matyáš Pokorný on 2019-04-26.

module ROM
	module HTTP
		Security = Struct.new(:cert, :key, :keyword_init => true)
	end
end