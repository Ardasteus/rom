module ROM
  class HTTPListenerJob < ROM::Job

    # Instantiates the {ROM::HTTPListenerJob} class
    # @param [TCPServer] tcp_server TCP server provided by the {ROM::HTTPService} class
    # @param [ROM::JobPool] job_pool Job pool provided by the {ROM::HTTPService} class
    def initialize(tcp_server, job_pool, https = false, cert = "", redirect = "")
      if https == false
        @server = tcp_server
      else
        if cert == ""
          cft = generate_cert
        else
          raw = File.read cert
					cft = OpenSSL::X509::Certificate.new raw
        end
        ctx = OpenSSL::SSL::SSLContext.new
				ctx.cert = cft
				ctx.key = @key
				ctx.npn_protocols = ['http/1.1']
        @server = OpenSSL::SSL::SSLServer.new tcp_server, ctx
				@server.start_immediately = true
      end
      @job_pool = job_pool
      @redirect = redirect
    end

    # Overrides the base {ROM::Job} job_task method. Accepts the client and creates a {ROM::HTTPRespondJob} job to handle him.
    def job_task
      loop do
        respond_job = HTTPRespondJob.new(@server.accept, @redirect)
        @job_pool.add_job(respond_job)
      end
    end

    def generate_cert
      @key = OpenSSL::PKey::RSA.new 2048
      public_key = @key.public_key
      subject = "/C=CZ/O=company.com/OU=company.com/CN=localhost/L=Prague/ST=Prague"

      cert = OpenSSL::X509::Certificate.new
      cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
      cert.not_before = Time.now
      cert.not_after = Time.now + 365 * 24 * 60 * 60
      cert.public_key = public_key
      cert.serial = 1
      cert.version = 2

      ef = OpenSSL::X509::ExtensionFactory.new(nil, cert)
      ef.issuer_certificate = cert
      cert.extensions = [
				ef.create_extension("basicConstraints","CA:TRUE"),
				ef.create_extension("keyUsage", "keyEncipherment"),
				ef.create_extension("subjectKeyIdentifier", "hash"),
				ef.create_extension("extendedKeyUsage", "serverAuth")
      ]
      cert.add_extension ef.create_extension("authorityKeyIdentifier", "keyid:always,issuer:always")

      cert.sign @key, OpenSSL::Digest::SHA1.new

      return cert
    end
  end
end