module ROM
  class HTTPRespondJob < ROM::Job
    def initialize(client, request)
      @client = client
      @http_request = HTTPRequest.new(request, request)
    end
    def job_task
      response = HTTPResponse.new(code: 200, data: "Cool and Good")
      client.write(response.response)
    end
  end
end