require 'thread'

module ROM

  # Holds [Job] classes in either a collection of currently running jobs or in a queue
  class JobPool

    # Count of currently running jobs
    # @return [integer]
    def count
      @running.length
    end

    # Instantiates the {ROM::JobPool} class
    # @param [int] capacity Maximum capacity of concurrent running Jobs in the pool, if 0 then not limited
    def initialize(capacity)
      @semaphore = Mutex.new
      @capacity = capacity
      @queue = Array.new
      @running = Set.new
    end

    # Adds a new {ROM::Job} to the job pool, if pool is full, job will be added to a queue
    # @param [ROM::Job] job Job to be added to the pool
    def add_job(job)
      if @capacity != 0 and @running.length == @capacity
        @semaphore.synchronize do
          @queue.push(job)
          end
      else
        job.attach_job_pool(self)
        @running.add(job)
        job.run
      end
    end

    # Called when {ROM::Job} notifies the pool that its state has changed
    # @param [ROM::Job] job Job that raised the event
    def update_job(job)
      @running.delete(job) unless job.state == :running
      if job.state == :finished and @queue.length > 0
        @semaphore.synchronize do
            add_job(@queue.pop)
        end
      elsif  job.state == :failed
        handle_failed(job)
      end
    end

    # Waits for all jobs to finish, including the queue.
    def await_jobs
      until @queue.count + @running.count == 0
        @running.first.await
      end
    end

    # Called when {ROM::Job} failed executing its task
    # @param [ROM::Job] job Job that raised the event
    def handle_failed(job)
    end
  end
end
