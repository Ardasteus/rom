class Job
  def initialize()
    @state = :not_started
  end

  def state
    @state
  end

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

  def job_task
    puts "Hello there I am a job"
  end

  def notify_jobpool
    @observer.update(self)
  end

  def attach_jobpool(pool)
    @observer = pool
  end
end