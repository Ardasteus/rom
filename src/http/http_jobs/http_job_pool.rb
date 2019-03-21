module ROM
	class HTTPJobPool < ROM::JobPool
		def handle_failed(job)
			puts "Http response failed"
		end
	end
end