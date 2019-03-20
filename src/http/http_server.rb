require 'socket'

module ROM
  class HTTPServer
    include Component

    def initialize(jobserver, pool_name, pool_capacity, address, port)
      @jobserver = jobserver
      @server = TCPServer.new(address, port)
      @job_pool = pool_name
      @address = address
      @port = port
      @jobserver.add_job_pool(@job_pool, pool_capacity)
    end
  end
end