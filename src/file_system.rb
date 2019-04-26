module ROM
	class FileSystem < Service
		def data=(rt)
			raise('File system may not change while it is running!') if status == :running
			@data = rt
		end

		def data
			@data
		end

		def temp
			path('temp')
		end

		def cert
			path('cert')
		end

		def initialize(itc)
			super(itc, 'File system')
			@data = Pathname.new(File.expand_path('~')).join('.rom')
		end

		def up
			temp.rmtree if temp.exist?
			temp.mkpath
			cert.mkpath
		end

		def down
			temp.rmtree
		end

		def path(*p)
			return @data.join(*p)
		end
	end
end