module ROM
	#Base class for all data serializers
	class SerializerProvider
		include Component
		
		# Instantiates the {ROM::DataSerializers::Serializer} class
		# @param [ROM::Interconnect] itc Interconnect
		def initialize(itc)
			@itc = itc
			@content_types = []
		end
		
		def get_serializer(type, encoding)
		
		end
		
		# Checks if the given content type is supported by this serializer
		# @param [String] content_type Content-Type to check
		def accepts?(content_type)
			return false if content_type == nil
			@content_types.include?(content_type.split(';').first.chomp)
		end
	end
end