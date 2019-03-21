module ROM
  class HTTPResponse
    EOL = "\r\n"
    def code
      @code
    end

    def headers
      @headers
    end

    def initialize(code, content, **headers)
        @code = code
        @headers = create_headers(content, headers)
        @content = content
    end

    def create_headers(content, headers)
        hdrs = {}

        content.headers.each_pair do |key, value|
          hdrs[header_key(key)] = value
        end

        headers.each_pair do |key, value|
          hdrs[header_key(key)] = value
        end

        hdrs["content-length"] = 0 if hdrs["content-length"] == nil
        return hdrs
    end

    def header_key(header)
      header.to_s.gsub("_", "-")
    end

    def stringify
      response = "HTTP/1.1 #{@code} OK#{EOL}"

      @headers.each_pair do |key, value|
        response += key + ": " + value + EOL
      end
      response += EOL
      response += content.stream.read

      return response
    end
  end
end