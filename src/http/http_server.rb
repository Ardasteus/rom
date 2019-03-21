module ROM
  class HTTPServer
    include Component

    def initialize(itc, address, port, pool_name = :clients)
      @job_server = itc.lookup(JobServer).first
      @tcp_server = TCPServer.new(address, port)
      @address = address
      @job_pool_name = pool_name
      @port = port
      @state = :not_running
    end

    def run()
      unless @state == :running
        @state == :running
        listener_job = HTTPListenerJob.new(@tcp_server, @job_server[@job_pool_name])
        @job_server.add_job_to_pool(:services, listener_job)
      end
    end

    def self.register(itc)
      [self.new(itc, 'localhost', 80)]
    end
  end
end