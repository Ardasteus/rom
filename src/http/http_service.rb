module ROM
  module HTTP

    # Service that uses [HTTPConfig] to create HTTP servers
    class HTTPService < ROM::Service

      # Instantiates the {ROM::HTTP::HTTPService} class
      # @param [Interconnect] itc Interconnect
      def initialize(itc)
        super(itc, "HTTP Service", "Provides access to API via HTTP and HTTPS")
      end

      # Starts up the service, which then proceeds to create {HTTPListenerJob} jobs as defined in config
      def up
        log = @itc.fetch(LogServer)
        conf = @itc.lookup(HTTPConfig).first
        job_server = @itc.lookup(JobServer).first
        resolver = @itc.lookup(HTTPAPIResolver).first
        job_server.add_job_pool(:services, 0) unless job_server[:services] != nil
        job_server.add_job_pool(:clients, 0) unless job_server[:clients] != nil
        conf.bind.each do |b|
          log.debug("Adding HTTP#{(b.https ? 'S' : '')} binding #{b.address}:#{b.port}#{(b.redirect == nil ? '' : " -> #{b.redirect}")}...")
          if not b.https
            job_server[:services].add_job(HTTPListenerJob.new(resolver, TCPServer.new(b.address, b.port), job_server[:clients], false, "", b.redirect))
          else
            job_server[:services].add_job(HTTPListenerJob.new(resolver, TCPServer.new(b.address, b.port), job_server[:clients], b.https, b.cert_path, b.redirect))
          end
        end
      end

      def down

      end

      # Transforms HTTP address to HTTPS one
      # @param [String] address Address to transform
      def transform_address(address)
        transformed = address
        if transformed.include? "http"
          transformed.sub! 'http' 'https'
        else
          transformed.insert(0, 'https://')
        end
        return transformed
      end
    end
  end
end
