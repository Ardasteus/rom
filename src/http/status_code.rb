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
		
		def to_s
			"#{@code} #{@note}"
		end

    CONTINUE            = self.new(100, "Continue")
    SWITCHING_PROTOCOLS = self.new(101, "Switching Protocols")
    OK                  = self.new(200, "OK")
    CREATED             = self.new(201, "Created")
    MOVED_PERMANENTLY   = self.new(301, "Moved Permanently")
    BAD_REQUEST         = self.new(400, "Bad Request")
    NOT_FOUND           = self.new(404, "Not Found")
  end
end