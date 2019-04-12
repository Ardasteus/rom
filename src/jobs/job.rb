module ROM
  class Job
		def state
			@state
		end
	
		def value
			@value
		end
		
		def name
			@name
		end
		
		def exception
			@exception
		end
		
    # Instantiates the {ROM::Job} class
    def initialize(nm)
			@name = nm
			@state = :not_started
    end

    # Encapsulates and starts the job, automatically notifies the {ROM::JobPool} at the end
    def run(log)
        @state = :running
        @thread = Thread.new do
          begin
            @value = job_task(log)
            @state = :finished
          rescue Exception => ex
            @state = :failed
            @exception = ex
          ensure
            notify_job_pool
          end
      end
    end

    # Task that the job is supposed to perform
    def job_task(log)
      # pass
    end

    def await
      @thread.join if @state == :running
      @value
    end
    #  Notifies {ROM::JobPool} about a state change
    def notify_job_pool
      @observer.update_job(self) unless @observer == nil
    end

    # Attaches {ROM::JobPool} as an observer, {ROM::JobPool} calls this when adding the job
    def attach_job_pool(pool)
      @observer = pool
    end
  end
end