# Created by Matyáš Pokorný on 2019-03-23.

module ROM
	# Represents a service component
	#
	# @example A loop service
	# 	class LoopService < Service
	# 		def initialize(itc)
	# 			super(itc, 'loop', 'Keeps on looping')
	# 			@thread = nil
	# 			@stop = false
	# 		end
	#
	# 		def up
	# 			@stop = false
	# 			@thread = Thread.new { until @stop; end }
	# 		end
	#
	# 		def down
	# 			@stop = true
	# 			@thread.join
	# 		end
	# 	end
	class Service
		include Component
		
		# Gets the name of service
		# @return [String] Name of service
		def name
			@name
		end
		
		# Gets the description of service
		# @return [String] Description of service
		def description
			@desc
		end
		
		# Gets the status of service
		# @return [String] Status of service
		def status
			@status
		end
		
		# Gets list of service classes on which this service depends
		# @return [Array<Class>] Service dependencies
		def dependencies
			@dep
		end
		
		# Instantiates the {ROM::Service} class
		# @param [ROM::Interconnect] itc Instance of registering interconnect
		# @param [String] name Name of service
		# @param [String] desc Description of service
		# @param [Class] dep List of service dependencies
		def initialize(itc, name, desc = '', *dep)
			@itc = itc
			@name = name
			@desc = desc
			@jobs = []
			@status = :not_started
			@dep = dep
		end
		
		# Starts the service
		def start
			return unless @status == :not_started
			@itc.fetch(LogServer).debug("Starting service '#{@name}'...")
			@status = :starting
			up
			@status = :running
		end
		
		# Called to start the service
		# @abstract
		def up
			raise 'Method not implemented!'
		end
		
		# Stops the service
		def stop
			return unless @status == :running
			@itc.fetch(LogServer).debug("Stopping service '#{@name}'...")
			@status = :stopping
			down
			@status = :not_started
		end
		
		# Called to stop the service
		# @abstract
		def down
			raise 'Method not implemented!'
		end
		
		protected :up, :down
	end
end