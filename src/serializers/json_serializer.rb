module ROM
  module DataSerializers

    # JSON Serializer/Deserializer class
    class JSONSerializer < Serializer
			
      # Preffered content type 
      # @return [String]
      def type
				@content_types.first
      end

      # Instantiates the {ROM::DataSerializers::JSONSerializer} class
      # @param [ROM::Interconnect] itc Interconnect
      def initialize(itc)
        super(itc)
        @content_types = ['application/json']
      end

      # Deserializes a json data stream into a n object
      # @param [Stream] stream Data stream to deserialize
      def to_object(stream)
        obj = JSON.parse(stream)
        return obj
      end

      # Serializes an object into a json data stream
      # @param [Object] obj Object to serialize
      def from_object(obj)
        json_string = JSON.generate(obj)
        return StringIO.new(json_string)
      end
    end
  end
end