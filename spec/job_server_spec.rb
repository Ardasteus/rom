require_relative 'spec_helper'
module ROM
  describe Job do
    context "When creating and running a new job" do
      it 'should run successfully and execute the task its given.' do
        job = Job.new()
        job.run()
        job.await
        state = job.state
        expect(state).to eq :finished
      end
    end
  end

  describe JobPool do
    context "When adding a job to the pool" do
      it 'should add it to currently running jobs, start it and when it has finished, remove it.' do
        pool = JobPool.new(0)
        job = Job.new
        pool.add_job(job)
        job.await
        state = job.state
        count = pool.count
        expect(state).to eq :finished
        expect(count).to eq 0
      end
    end
    context "When adding a job to a pool that is limited" do
      it 'should it should check if there is enough space for it and if there is not, add it to a queue and wait for space to free up' do
        pool = JobPool.new(1)
        jobs = []
        10.times do 
          job = Job.new
          jobs << job
          pool.add_job(job)
        end
        pool.await_jobs
        expect(pool.count).to eq 0
        jobs.each do |job|
          expect(job.state).to eq :finished
        end
      end
    end
  end
end