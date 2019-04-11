module ROM
  module DataSerializers
    class Serializer
    include Component

    # Instantiates the {ROM::DataSerializers::Serializer} class
    # @param [ROM::Interconnect] itc Interconnect
      def initialize(itc)
        @itc = itc
        @content_types = []
      end

    # Deserializes a stream of data to an object
    # @param [Stream] stream Data stream to serialize
      def to_object(stream)

      end

    # Serializes an object into a data stream
    # @param [Object] obj Object to serialize
      def from_object(obj)

      end

    # Checks if the given content type is supported by this serializer
    # @param [String] content_type Content-Type to check
    def is_content_type(content_type)
      @content_types.include?(content_type)
      end
    end
  end
end