module ROM
  class HTTPService < ROM::Service
    def initialize(itc)
      super(itc, "HTTP Service", "Magic")
    end

    def up
      conf = @itc.lookup(HTTPConfig).first
      job_server = @itc.lookup(JobServer).first
      job_server.add_job_pool(:services, 0) unless job_server[:services] != nil
      job_server.add_job_pool(:clients, 0) unless job_server[:clients] != nil
      conf.bind.each do |binding|
        address, port, https, cert_path = binding.split(',')
        if https == "false"
          job_server[:services].add_job(HTTPListenerJob.new(TCPServer.new(address, port.to_i), job_server[:clients]))
        else
          if cert_path == nil
          job_server[:services].add_job(HTTPListenerJob.new(TCPServer.new(address, port.to_i), job_server[:clients], https))
          else
            job_server[:services].add_job(HTTPListenerJob.new(TCPServer.new(address, port.to_i), job_server[:clients], https, cert_path))
          end
        end
      end
    end

    def down

    end
  end
end