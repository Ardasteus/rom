module ROM
  class HTTPRespondJob < ROM::Job
    def initialize(client, request)
      @client = client
      @http_request = HTTPRequest.new(request, request)
    end
    def job_task
      msg = "Cool and good"
      http_content = HTTPContent.new(msg, :content_length => msg.length)
      http_response = HTTPResponse.new(200, http_content)
      client.write(http_response.stringify)
    end
  end
end