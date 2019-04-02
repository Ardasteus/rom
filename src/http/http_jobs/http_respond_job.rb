module ROM
  class HTTPRespondJob < ROM::Job

    def http_request
      @http_request
    end

    def client
      @client
    end

    # Instantiates the {ROM::HTTPResponseJob} class
    def initialize(client, redirect = "")
      @client = client
      @http_request = HTTPRequest.new(client)
      @redirect = redirect
    end
    
    def job_task
      if @redirect == ""
        msg = "Cool and good"
        http_content = HTTPContent.new(StringIO.new(msg), :content_length => msg.length)
        http_response = HTTPResponse.new(ROM::StatusCode::OK, http_content)
      else
        http_content = HTTPContent.new(nil , :location => "#{@redirect}#{@http_request.path}")
        http_response = HTTPResponse.new(ROM::StatusCode::Moved_Permanently, http_content)
      end
      resp = http_response.stringify
      client.write(resp)
      client.close
      return http_response
    end
  end
end