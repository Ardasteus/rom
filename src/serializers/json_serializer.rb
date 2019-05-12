module ROM
  module DataSerializers
    # JSON Serializer/Deserializer class
    class JSONSerializer < Serializer
			
      # Preferred content type
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
      # @param [IO] stream Data stream to deserialize
      def to_object(stream)
        JSON.parse(stream)
      end

      # Serializes an object into a json data stream
      # @param [Object] obj Object to serialize
      def from_object(obj)
        obj = obj.to_object if obj.is_a?(Model)
        
				StringIO.new(JSON.generate(obj))
      end
    end
  end
end