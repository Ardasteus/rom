# Created by Matyáš Pokorný on 2019-03-23.

module ROM
	class Service
		include Component
		
		def name
			@name
		end
		
		def description
			@desc
		end
		
		def initialize(itc, name, desc = '')
			@itc = itc
			@name = name
			@desc = desc
			@jobs = []
			@status = :not_started
		end
		
		def start
			return unless @status == :not_started
			@status = :starting
			up
			@status = :running
		end
		
		def up
			raise 'Method not implemented!'
		end
		
		def stop
			return unless @status == :running
			@status = :stopping
			down
			@status = :not_started
		end
		
		def down
			raise 'Method not implemented!'
		end
	end
end