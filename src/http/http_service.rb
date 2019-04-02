module ROM
  class HTTPService < ROM::Service

    # Instantiates the {HTTPService} class
    # @param [Interconnect] itc Interconnect
    def initialize(itc)
      super(itc, "HTTP Service", "Magic")
    end

    # Starts up the service, which then proceeds to create {HTTPListenerJob} jobs as defined in config
    def up
      conf = @itc.lookup(HTTPConfig).first
      job_server = @itc.lookup(JobServer).first
      job_server.add_job_pool(:services, 0) unless job_server[:services] != nil
      job_server.add_job_pool(:clients, 0) unless job_server[:clients] != nil
      conf.bind.each do |b|
        if b.https == false
          job_server[:services].add_job(HTTPListenerJob.new(TCPServer.new(b.address, b.port), job_server[:clients], false, "", b.redirect))
        else
          if b.cert_path == ""
            job_server[:services].add_job(HTTPListenerJob.new(TCPServer.new(b.address, b.port), job_server[:clients], b.https, "", b.redirect))
          else
            job_server[:services].add_job(HTTPListenerJob.new(TCPServer.new(b.address, b.port), job_server[:clients], b.https, b.cert_path, b.redirect))
          end
        end
      end
    end

    def down

    end

    # Transforms HTTP address to HTTPS one
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