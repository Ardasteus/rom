module ROM
  class HTTPServer
    include Component

    # Instantiates the {ROM::HTTPServer} class
    # @param [ROM::Interconnect] itc Interconnect
    # @param [string] address Address of the HTTP server
    # @param [int] port Port of the HTTP address
    # @param [symbol] pool_name Name of pool where {ROM::HTTPRespondJob} that this server creates go
    def initialize(itc, address, port, pool_name = :clients)
      @job_server = itc.lookup(JobServer).first
      @tcp_server = TCPServer.new(address, port)
      @address = address
      @job_pool_name = pool_name
      @port = port
      @state = :not_running
    end

    # Runs the server
    def run()
      unless @state == :running
        @state == :running
        listener_job = HTTPListenerJob.new(@tcp_server, @job_server[@job_pool_name])
        @job_server.add_job_to_pool(:services, listener_job)
      end
    end

    # Registers the server in the interconnect
    def self.register(itc)
      [self.new(itc, 'localhost', 80)]
    end
  end
end