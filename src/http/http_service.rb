module ROM
	module HTTP
		
		# Service that uses [HTTPConfig] to create HTTP servers
		class HTTPService < ROM::Service
			
			# Instantiates the {ROM::HTTP::HTTPService} class
			# @param [Interconnect] itc Interconnect
			def initialize(itc)
				super(itc, "HTTP Service", "Provides access to API via HTTP and HTTPS")
			end
			
			# Starts up the service, which then proceeds to create {HTTPListenerJob} jobs as defined in config
			def up
				log        = @itc.fetch(LogServer)
				fs         = @itc.fetch(FileSystem)
				conf       = @itc.lookup(HTTPConfig).first
				job_server = @itc.lookup(JobServer).first
				resolver   = @itc.lookup(HTTPAPIResolver).first
				job_server.add_job_pool(:services, 0) unless job_server[:services] != nil
				job_server.add_job_pool(:clients, 0) unless job_server[:clients] != nil
				conf.bind.each do |b|
					log.debug("Adding HTTP#{(b.https ? 'S' : '')} binding #{b.address}:#{b.port}#{(b.redirect == nil ? '' : " -> #{b.redirect}")}...")
					sec = nil
					if b.https
						if b.cert_path != nil
							raise("Certificate file '#{b.cert_path}' not found!") unless File.exist?(b.cert_path)
							raise("Key file '#{b.cert_path}' not found!") unless File.exist?(b.key_path)
							cert = OpenSSL::X509::Certificate.new(File.open(b.cert_path))
							key  = OpenSSL::PKey::RSA.new(File.open(b.key_path))
							sec = Security.new(:cert => cert, :key => key)
						else
							cf = fs.cert.join("#{b.hash}.cer.base64")
							kf = fs.cert.join("#{b.hash}.pem.base64")
							raise("Key file '#{kf}' for self-signed certificate '#{cf}' not found!") if cf.file? and not kf.file?
							raise("Self-signed certificate '#{cf}' for key file '#{kf}' not found!") if not cf.file? and kf.file?
							if cf.file?
								log.trace("Using self-signed certificate '#{cf}'...")
								cert = OpenSSL::X509::Certificate.new(Base64.decode64(cf.read))
								key  = OpenSSL::PKey::RSA.new(Base64.decode64(kf.read))
								sec = Security.new(:cert => cert, :key => key)
							else
								log.trace("Generating self-signed certificate '#{cf}'...")
								sec = generate_sec(b.address)
								cf.write(Base64.strict_encode64(sec.cert.to_s), File::WRONLY | File::CREAT)
								kf.write(Base64.strict_encode64(sec.key.to_s), File::WRONLY | File::CREAT)
							end
						end
					end
					
					job_server[:services].add_job(HTTPListenerJob.new(resolver, TCPServer.new(b.address, b.port), job_server[:clients], sec, b.redirect))
				end
			end
			
			def down
			
			end
			
			# Transforms HTTP address to HTTPS one
			# @param [String] address Address to transform
			def transform_address(address)
				transformed = address
				if transformed.include? "http"
					transformed.sub! 'http' 'https'
				else
					transformed.insert(0, 'https://')
				end
				return transformed
			end
			
			# Generates a self-signed certificate. Only used when one is not provided.
			def generate_sec(host)
				key        = OpenSSL::PKey::RSA.new 2048
				public_key = key.public_key
				subject    = "/C=CZ/O=company.com/OU=company.com/CN=#{host}/L=Prague/ST=Prague"
				
				cert            = OpenSSL::X509::Certificate.new
				cert.subject    = cert.issuer = OpenSSL::X509::Name.parse(subject)
				cert.not_before = Time.now
				cert.not_after  = Time.now + 365 * 24 * 60 * 60
				cert.public_key = public_key
				cert.serial     = 1
				cert.version    = 2
				
				ef                    = OpenSSL::X509::ExtensionFactory.new(nil, cert)
				ef.issuer_certificate = cert
				cert.extensions       = [
					ef.create_extension("basicConstraints", "CA:TRUE"),
					ef.create_extension("keyUsage", "keyEncipherment"),
					ef.create_extension("subjectKeyIdentifier", "hash"),
					ef.create_extension("extendedKeyUsage", "serverAuth")
				]
				cert.add_extension ef.create_extension("authorityKeyIdentifier", "keyid:always,issuer:always")
				
				cert.sign key, OpenSSL::Digest::SHA1.new
				
				return Security.new(:cert => cert, :key => key)
			end
		end
	end
end
