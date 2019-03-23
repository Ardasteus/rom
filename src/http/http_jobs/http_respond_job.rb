module ROM
  class HTTPRespondJob < ROM::Job

    def http_request
      @http_request
    end

    def client
      @client
    end

    # Instantiates the {ROM::HTTPResponseJob} class
    def initialize(client)
      @client = client
      @http_request = HTTPRequest.new(client)
    end
    
    def job_task
      method = @http_request.method
      if method == "GET"
        msg = "Cool and good"
        http_content = HTTPContent.new(StringIO.new(msg), :content_length => msg.length)
        http_response = HTTPResponse.new(200, http_content)
      elsif method == "POST"

      end
      client.write(http_response.stringify)
      client.close
      return http_response
    end
  end
end