# Created by Matyáš Pokorný on 2019-06-18.

module ROM
	class MailStorage < Service
		HEADERS_SUFFIX = '.headers'
		
		def initialize(itc)
			super(itc, 'Mail storage', 'Manages mails on disk', Filesystem)
			@itc = itc
			@root = nil
		end
		
		def up
			@root = @itc.fetch(Filesystem).mails
		end
		
		def down
		
		end
		
		def exists?(id)
			(@root + id).exist?
		end
		
		def store(part)
			id = new_id
			(@root + id).open('wb+') do |h|
				IO.copy_stream(part.data, h)
			end
			
			(@root + "#{id}#{HEADERS_SUFFIX}").open('w+') do |h|
				h.write(JSON.generate(part.headers))
			end
			
			id
		end
		
		def load(id)
			raise(Exception.new('Mail not found!')) unless exists?(id)
			
			hdr = nil
			(@root + "#{id}#{HEADERS_SUFFIX}").open do |h|
				hdr = JSON.load(h).collect { |kvp| [kvp[0].to_sym, kvp[1]] }.to_h
			end
			
			data = (@root + id).open
			
			MailPart.new(hdr, data)
		end
		
		def drop(id)
			raise(Exception.new('Mail not found!')) unless exists?(id)
			
			(@root + id).delete
			(@root + "#{id}#{HEADERS_SUFFIX}").delete
		end
		
		def new_id
			loop do
				id = UUID.generate(:compact)
				return id unless (@root + id).exist?
			end
		end
		
		private :new_id
	end
end