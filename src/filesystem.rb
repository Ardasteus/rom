module ROM
	# Provides the application with uniform access to filesystem under custom root
	class Filesystem < Service
		# Sets the root of filesystem
		# @param [Pathname] rt Root of filesystem
		def root=(rt)
			raise('Filesystem may not change while it is running!') if status == :running
			@root = rt
		end

		# Gets the root of filesystem
		# @return [Pathname] Root of filesystem
		def root
			@root
		end

		# Gets the path of temporary directory (cleared with ever run)
		# @return [Pathname] Path of temporary directory
		def temp(*file)
			path('temp', *file)
		end

		# Gets the path of self-signed certificates directory
		# @return [Pathname] Path of self-signed certificates directory
		def cert
			path('cert')
		end
		
		def mails
			path('mails')
		end

		# Instantiates the {ROM::Filesystem} class
		# @param [ROM::Interconnect] itc Interconnect which registers this instance
		def initialize(itc)
			super(itc, 'Filesystem', 'Provides a uniform access to the application filesystem')
			@root = Pathname.new(File.expand_path('~')).join('.rom')
		end
		
		# Starts the service. Clears temp and ensures directory structure exists
		def up
			temp.rmtree if temp.exist?
			temp.mkpath
			cert.mkpath
			mails.mkpath
		end
		
		# Stops the service. Clears temp
		def down
			temp.rmtree
		end

		# Gets a path relative to the root
		# @param [String] p Relative path
		# @return [Pathname] Absolute resolved path
		def path(*p)
			return @root.join(*p)
		end
	end
end