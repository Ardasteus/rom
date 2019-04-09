module ROM
  module DataSerializers
    class JSONSerializer < Serializer
			def type
				@content_types.first
			end
			
      def initialize(itc)
        super(itc)
        @content_types = ['application/json']
      end

      def to_object(stream)
        obj = JSON.parse(stream)
        return obj
      end

      def from_object(obj)
        json_string = JSON.generate(obj)
        return StringIO.new(json_string)
      end
    end
  end
end