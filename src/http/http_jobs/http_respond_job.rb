module ROM
  class HTTPRespondJob < ROM::Job

    def http_request
      @http_request
    end

    def client
      @client
    end

    # Instantiates the {ROM::HTTPResponseJob} class
    # @param [String] redirect Location where to redirect all requests, if empty then no redirect
    def initialize(client, redirect = "")
			super('HTTP connection handler job')
      @client = client
      @http_request = HTTPRequest.new(client)
      @redirect = redirect
    end

    # Responds to the client, if redirect is turned on it redirects him.
    def job_task(log)
      if @redirect == nil
        msg = "Cool and good"
        http_content = HTTPContent.new(StringIO.new(msg), :content_length => msg.length)
        http_response = HTTPResponse.new(ROM::StatusCode::OK, http_content)
      else
        http_content = HTTPContent.new(nil , :location => "#{@redirect}#{@http_request.path}")
        http_response = HTTPResponse.new(ROM::StatusCode::MOVED_PERMANENTLY, http_content)
      end
      resp = http_response.stringify
      client.write(resp)
      client.close
      return http_response
    end
  end
end