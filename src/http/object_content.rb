# Created by Matyáš Pokorný on 2019-04-09.

module ROM
	module HTTP
		class ObjectContent < HTTPContent
			def initialize(obj, ser, **headers)
				@obj = obj
				@ser = ser
				io = ser.from_object(obj)
				super(io, :content_type => ser.type, :content_length => io.length, **headers)
			end
		end
	end
end