module ROM  
  class JobServer
    # Instantiates the {ROM::JobServer} class
    def initialize()
      @job_pools = {}
    end

    # Adds a new {ROM::JobPool} to the server
    # @param [symbol] key Symbol defining the job pool
    # # @param [int] capacity Capacity of the newly created pool, defaults to 0, check {ROM::JobPool} initialize for more info
    def add_job_pool(key, capacity = 0)
      if get_job_pool(key) == nil
      @job_pools = {key => JobPool.new(capacity)}
      end
    end

    # Returns {ROM::JobPool} from the server
    # @param [symbol] key Symbol defining the job pool
    def get_job_pool(key)
      return @job_pools.fetch(key)
    end

    # Adds {ROM::Job} to a specified {ROM::JobPool}, if the pool doesnt exist it is added
    # @param [symbol] key Symbol defining the job pool
    # # @param [{ROM::Job}] job Job to add to the pool
    def add_job_to_pool(key, job)
      pool = get_job_pool(key)
      if pool == nil # I guess
        add_job_pool(key)
      end
      pool.add_job(job)
    end
  end
end