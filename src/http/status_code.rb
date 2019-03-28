module ROM
  class StatusCode

    def code
      @code
    end

    def note
      @note
    end

    def initialize(code, text)
      @code = code
      @note = text
    end

    Continue = self.new(100, "Continue")
    Switching_Protocols = self.new(101, "Switching Protocols")
    OK = self.new(200, "OK")
    Created = self.new(201, "Created")
    Bad_Request = self.new(400,"Bad Request")
    Not_Found = self.new(404, "Not Found")
  end
end