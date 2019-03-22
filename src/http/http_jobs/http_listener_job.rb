module ROM
  class HTTPListenerJob < ROM::Job
    def initialize(tcp_server, job_pool)
      @tcp_server = tcp_server
      @job_pool = job_pool
    end
    def job_task
      loop do
        respond_job = HTTPRespondJob.new(@tcp_server.accept)
        @job_pool.add_job(respond_job)
      end
    end
  end
end