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
      conf.bind.each do |binding|
        address, port = binding.split(':')
        job_server[:services].add_job(HTTPListenerJob.new(TCPServer.new(address, port.to_i), job_server[:clients]))
      end
    end
  end
end