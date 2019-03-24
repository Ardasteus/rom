module ROM
  class HTTPResponse
    EOL = "\r\n"
    def code
      @code
    end

    def headers
      @headers
    end

    def content
      @content
    end

    # Instantiates the {ROM::HTTPResponse} class
    # @param [int] code Code of the response, for example 200 OK
    # @param [ROM::HTTPContent] content Content of the response
    # @param [hash] headers Custom headers that override the content ones
    def initialize(code, content, **headers)
        @code = code
        @headers = create_headers(content, headers)
        @content = content
    end

    # Merges the content and custom header together, custom ones have priority
    # @param [ROM::HTTPContent] content Content of the response
    # @param [hash] headers Custom headers
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

    # Transforms the header back from symbol to a string
    # @param [symbol] header Header to transform
    def header_key(header)
      header.to_s.gsub("_", "-")
    end

    # Creates a string from the whole response
    def stringify
      response = "HTTP/1.1 #{@code} OK#{EOL}"

      @headers.each_pair do |key, value|
        response += key + ": " + value.to_s + EOL
      end
      response += EOL
      response += @content.stream.read

      return response
    end
  end
end