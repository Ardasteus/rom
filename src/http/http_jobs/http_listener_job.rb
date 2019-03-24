module ROM
  class HTTPListenerJob < ROM::Job

    # Instantiates the {ROM::HTTPListenerJob} class
    # @param [TCPServer] tcp_server TCP server provided by the {ROM::HTTPServer} class
    # @param [ROM::JobPool] job_pool Job pool provided by the {ROM::HTTPServer} class
    def initialize(tcp_server, job_pool)
      @tcp_server = tcp_server
      @job_pool = job_pool
    end

    # Overrides the base {ROM::Job} job_task method. Accepts the client and creates a {ROM::HTTPRespondJob} job to handle him.
    def job_task
      loop do
        respond_job = HTTPRespondJob.new(@tcp_server.accept)
        @job_pool.add_job(respond_job)
      end
    end
  end
end