module ROM
  class JSONSerializer < Serializer

    def to_object(stream)
      obj = JSON.parse(stream)
      return obj
    end

    def from_object(obj)
      json_string = JSON.generate(obj)
      return json_string
    end
  end
end