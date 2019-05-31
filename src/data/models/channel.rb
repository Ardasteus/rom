# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	module DB
		# Chat channel
		class Channel < Model
			property :id, Integer
			property! :name, String, IndexAttribute[]
			property! :type, TypeChannel
			property :references, Integer, 1
		end
	end
end