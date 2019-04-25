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
			@data.join('tmp')
		end

		def initialize(itc)
			super(itc, 'Provides an abstract layer above the file system')
			@data = Pathname.new(File.expand_path('~')).join('.rom')
		end

		def up
			@temp.rmtree
			@temp.mkpath
		end

		def down
			@temp.rmtree
		end
	end
end