module ROM
  class Serializer
  include Component

    def initialize(itc)
      @itc = itc
      @content_types = []
    end

    def to_object(stream)

    end

    def from_object(obj)

    end

    def is_content_type(content_types)
      @content_types.include?(content_types)
    end
  end
end