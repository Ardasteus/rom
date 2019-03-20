module ROM
  class HTTPListenerJob < ROM::Job
    def initialize(tcp_server)
      @tcp_server = tcp_server
    end
    def job_task
      loop do
        client = @tcp_server.accept
        request = ''
        loop do
          part = ''
          begin
            part = client.read_nonblock(1024)
          rescue EOFError, IO::WaitReadable
            # ignored
          end
          break if part == ''
          request += part
        end
        respond_job = HTTPRespondJob.new(client, request)
        @job_server[@job_pool].add_job(respond_job)
      end
    end
  end
end