require 'socket'

module ROM
  class HTTPServer
    include Component

    def initialize(itc, job_server, pool_name, pool_capacity, address, port)
      @job_server = job_server
      @tcp_server = TCPServer.new(address, port)
      @job_pool = pool_name
      @address = address
      @port = port
      @job_server.add_job_pool(@job_pool, pool_capacity)
      @state = :not_running
    end

    def run
      unless @state == :not_running
        @state == :running
        listener_job = HTTPListenerJob.new(@tcp_server)
        @job_server[:services].add_job(listener_job)
      end
    end
  end
end