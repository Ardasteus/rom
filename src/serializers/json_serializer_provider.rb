module ROM
	module DataSerializers
		# JSON Serializer/Deserializer class
		class JsonSerializerProvider < SerializerProvider
			PRIMARY_TYPE = 'application/json'
			
			# Preferred content type
			# @return [String]
			def type
				@content_types.first
			end
			
			# Instantiates the {ROM::DataSerializers::JSONSerializer} class
			# @param [ROM::Interconnect] itc Interconnect
			def initialize(itc)
				super(itc)
				@content_types = [PRIMARY_TYPE]
			end
			
			def get_serializer(type, encoding)
				JsonSerializer.new(encoding)
			end
			
			class JsonSerializer < DataSerializer
				def type
					ContentType.new(PRIMARY_TYPE, :charset => @encoding.name)
				end
				
				def initialize(encoding)
					@encoding = encoding
				end
				
				# Deserializes a json data stream into a n object
				# @param [IO] io Data stream to deserialize
				def to_object(io)
					io.set_encoding(@encoding)
					JSON.parse(io)
				end
				
				# Serializes an object into a json data stream
				# @param [Object] obj Object to serialize
				def from_object(obj)
					obj = obj.to_object if obj.is_a?(Model)
					
					StringIO.new(JSON.generate(obj).encode(@encoding))
				end
			end
		end
	end
end