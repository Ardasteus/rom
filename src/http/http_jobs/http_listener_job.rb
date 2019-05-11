module ROM
  module HTTP

    # [ROM::Job] that listens and accepts clients and then creates a [HTTPRespondJob] to resolve the client's request
    class HTTPListenerJob < ROM::Job

      # Instantiates the {ROM::HTTPListenerJob} class
      # @param [ROM::HTTP::HTTPAPIResolver] api_resolver HTTP-API resolver
      # @param [TCPServer] tcp_server TCP server provided by the {ROM::HTTPService} class
      # @param [ROM::JobPool] job_pool Job pool provided by the {ROM::HTTPService} class
      # @param [ROM::HTTP::Security] sec
      # @param [String] redirect Location where to redirect all requests, if empty then no redirect
      def initialize(api_resolver, tcp_server, job_pool, sec = nil, redirect = "")
        super('HTTP listener job')
        if sec == nil
          @server = tcp_server
        else
          raise('Certificate not given!') if sec.cert == nil
          ctx = OpenSSL::SSL::SSLContext.new
          ctx.cert = sec.cert
          ctx.key = sec.key
          ctx.npn_protocols = ['http/1.1']
          @server = OpenSSL::SSL::SSLServer.new tcp_server, ctx
          @server.start_immediately = true
        end
        @api_resolver = api_resolver
        @job_pool = job_pool
        @redirect = redirect
      end

      # Overrides the base {ROM::Job} job_task method. Accepts the client and creates a {ROM::HTTPRespondJob} job to handle him.
      def job_task(log)
        loop do
          con = nil
          begin
            con = @server.accept
          rescue Exception => ex
            log.error('Failed to open an HTTP connection!', ex)
          end

          next if con == nil

          begin
            respond_job = HTTPRespondJob.new(@api_resolver, con, @redirect)
            @job_pool.add_job(respond_job)
          rescue Exception => ex
            log.error('Failed to create an HTTP response job!', ex)
          end
        end
      end
    end
  end
end
