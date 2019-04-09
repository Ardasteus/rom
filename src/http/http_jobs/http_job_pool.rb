module ROM
	module HTTP
		class HTTPJobPool < ROM::JobPool

			# Totally useful override
			def handle_failed(job)
				puts "Http response failed"
			end
		end
	end
end