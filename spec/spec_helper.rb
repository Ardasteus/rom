$LOAD_PATH.unshift(File.expand_path('../../src', __FILE__))
require 'simplecov'

SimpleCov.start do
  project_name 'Ruby on Mails'
  coverage_dir 'cover'
  add_group 'src', 'src'
  add_group 'spec', 'spec'
end

require 'rom'
require 'rspec'

describe Job do
  context "When creating and running a new job" do
    it 'should run successfully and execute the task its given.' do
      job = Job.new()
      job.run()
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
      state = job.state
      count = pool.running.count
      expect(state).to eq :finished
      expect(count).to eq 0
    end
  end
  context "When adding a job to a pool that is limited" do
    it 'should it should check if there is enough space for it and if there is not, add it to a queue and wait for space to free up' do
        pool = JobPool.new(1)
        10.times do pool.add_job(Job.new)
        state = job.state
        count = pool.running.count
        expect(state).to eq :finished
        expect(count).to eq 0
      end
    end
  end
end
