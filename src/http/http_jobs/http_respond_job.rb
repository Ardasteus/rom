module ROM
  module HTTP

    # [ROM::Job] that either redirects the client (if told to) or pases the client's request to [HTTPApiResolver]
    class HTTPRespondJob < ROM::Job

      # HTTP requests that this job is handling
      # @return [HTTPRequest]
      def http_request
        @http_request
      end

      # Client stream
      # @return [IO]
      def client
        @client
      end

      # Instantiates the {ROM::HTTPResponseJob} class
      # @param [ROM::HTTP::HTTPAPIResolver] resolver HTTP-API resolver
      # @param [Client] client Client connection stream
      # @param [String] redirect Location where to redirect all requests, if empty then no redirect
      def initialize(resolver, client, redirect = "")
        @client = client
        @http_request = HTTPRequest.new(client)
        @redirect = redirect
        @resolver = resolver
      end

      # Responds to the client, if redirect is turned on it redirects him.
      def job_task        
        if @redirect == nil
          http_response = @resolver.resolve(@http_request)
        else
          http_response = HTTPResponse.new(ROM::HTTP::StatusCode::MOVED_PERMANENTLY, nil, :location => "#{@redirect}#{@http_request.path}")
        end
        resp = http_response.stringify
      ensure
        client.write(resp)
        client.close
        return http_response
      end
    end
  end
end