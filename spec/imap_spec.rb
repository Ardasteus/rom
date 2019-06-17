require_relative 'spec_helper'
module ROM
  module IMAP
    class IMAPSpec

      describe IMAPJob do

        before(:each) do
          @itc = Interconnect.new
          @itc.register(JobServer)
        end

        it 'should connect to server and fetch inbox' do
          job_server = @itc.fetch(JobServer)
          job_server.add_job_pool(:imap, 0)
          job_server[:imap].add_job(IMAPJob.new("", "","mail.sssvt.cz", 143,))
          puts "done"
        end
      end
    end
  end
end