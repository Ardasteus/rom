require_relative 'spec_helper'
module ROM
  module SMTP

    describe SMTPJob do

      before(:each) do
        @itc = Interconnect.new
        @itc.register(JobServer)
      end

      it "should send a mail" do
        job_server = @itc.fetch(JobServer)
        job_server.add_job_pool(:smtp, 0)
        body = "Hey There
How are you
I am amazing.

Španko Roman

SMTP Testing.sro"
        message = SMTPMessage.new(body, :from => "",
                                  :to => "",
                                  :subject => "SMTP Testing")

        50.times do
          sleep(0.1)
          job_server[:smtp].add_job(SMTPJob.new(message, "mail.sssvt.cz", 25, "", ""))
        end
      end
    end

  end
end