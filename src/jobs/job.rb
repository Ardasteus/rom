module ROM

  # Class that encapsulates a task that needs to be executed
  class Job

    # Instantiates the {ROM::Job} class
    def initialize()
      @state = :not_started
    end

    # Current state of the job
    # @return [Symbol]
    def state
      @state
    end

    # Return value of the job
    # @return [Object]
    def value
      @value
    end

    # Encapsulates and starts the job, automatically notifies the {ROM::JobPool} at the end
    def run()
        @state = :running
        @thread = Thread.new do
          begin
            @value = job_task
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
    def job_task
      # pass
    end

    # Blocks the current thread and waits for the job to finish and returns the value
    # @return [Object]
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