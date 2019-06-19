# Created by Matyáš Pokorný on 2019-04-09.

module ROM
	module HTTP

		# {HTTPContent} that accepts a raw object and serializes it
		class ObjectContent < HTTPContent

			# Instantiates the {ROM::HTTPContent} class
			# @param [Object] obj Object used to create the content
			# @param [ROM::DataSerializers] ser Serializer to serialize the object with
			# @param [Hash] headers Optional headers
			def initialize(obj, ser, **headers)
				@obj = obj
				@ser = ser
				io = ser.from_object(obj)
				super(io, :content_type => ser.type.to_s, :content_length => io.length, **headers)
			end
		end
	end
end