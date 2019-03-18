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
    def run
      begin
        @state = :running
        job_task()
        @state = :finished
      rescue
        @state = :failed
      ensure
        notify_jobpool()
      end
    end

    # Task that the job is supposed to perform
    def job_task
      puts "Hello there I am a job"
    end

    #  Notifies {ROM::JobPool} about a state change
    def notify_jobpool
      @observer.update(self)
    end

    # Attaches {ROM::JobPool} as an observer, {ROM::JobPool} calls this when adding the job
    def attach_jobpool(pool)
      @observer = pool
    end
  end
end