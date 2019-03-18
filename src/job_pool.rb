class JobPool
  def initialize(size)
    @capacity = size
    @queue = Array.new
    if @capacity == 0
      @running = Array.new
    else
      @running = Array.new(size)
    end
  end

  def add_job(job)
    if @capacity != 0 and @running.count == @capacity
      @queue.push(job)
    else
      job.attach_jobpool(self)
      Thread.new(job.run)
      @running.push(job)
    end
  end

  def update_job(job)
    if job.state == :finished
      @running.delete(job)
      add_job(@queue.pop)
    elsif  job.state == :failed
      handle_failed(job)
    end
  end

  def handle_failed(job)

  end
end
