module ROM
  class JobServer
    include Component
    # Instantiates the {ROM::JobServer} class
    # @param [ROM::Interconnect] itc Interconnect
    def initialize(itc)
      @job_pools = {}
    end

    # Adds a new {ROM::JobPool} to the server
    # @param [symbol] key Symbol defining the job pool
    # @param [int] capacity Capacity of the newly created pool, defaults to 0, check {ROM::JobPool} initialize for more info
    def add_job_pool(key, job_pool)
      job_pool = JobPool.new(job_pool) if job_pool.is_a?(Integer)
      if self[key] == nil
        @job_pools[key] = job_pool
      end
    end

    # Returns {ROM::JobPool} from the server
    # @param [symbol] key Symbol defining the job pool
    def [](key)
      @job_pools[key]
    end

    # Removes specified {ROM::JobPool} from the server
    # @param [symbol] key Symbol defining the job pool
    def remove_job_pool(key)
      @job_pools.delete(key) if @job_pools[key] == nil
    end

    # Adds {ROM::Job} to a specified {ROM::JobPool}, if the pool doesnt exist it is added
    # @param [symbol] key Symbol defining the job pool
    # @param [ROM::Job] job Job to add to the pool
    def add_job_to_pool(key, job)
        pool = self[key]
        raise 'The specified job pool does not exist.' if pool == nil
        pool.add_job(job) unless pool == nil
    end
  end
end