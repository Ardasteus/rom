module ROM
  class Job

    # Instantiates the {ROM::Job} class
    def initialize()
      @state = :not_started
    end

    def state
      @state
    end

    # Encapsulates and starts the job, automatically notifies the {ROM::JobPool} at the end
    def run(job_server, job_pool)
      @job_server = job_server
      @job_pool = job_pool
      begin
        @state = :running
        @thread = Thread.new do
          begin
            job_task
            @state = :finished
          rescue Exception => ex
            @state = :failed
            @exception = ex
          ensure
            notify_job_pool
          end
        end
      end
    end

    # Task that the job is supposed to perform
    def job_task
      puts "Hello there I am a job"
    end

    def await
      @thread.join
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