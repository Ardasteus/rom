module ROM
  class HTTPRequest
    def method
      @method
    end

    def path
      @path
    end

    def version
      @version
    end

    def stream
      @io
    end

    def initialize(httprequest, io)
      @method, @path, @version = httprequest.lines[0].split
      @io = io
      parse_headers(httprequest)
    end

    def parse_headers(httprequest)
      @headers = {}
      httprequest.lines[1..-1].each do |line|
        header, value = line.split
        header = header.gsub("-", "_").downcase.to_sym
        headers[header] = value
      end
    end

    def [](header)
      header[header]
    end
  end
end