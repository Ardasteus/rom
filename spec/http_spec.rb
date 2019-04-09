require_relative 'spec_helper'
module ROM
	module HTTP
		describe HTTPRespondJob do
			context "When responding to a client request" do
				it 'should respond successful' do
					request = "POST /cgi-bin/process.cgi HTTP/1.1
User-Agent: Mozilla/4.0 (compatible; MSIE5.01; Windows NT)
Host: www.tutorialspoint.com
Content-Type: application/x-www-form-urlencoded
Content-Length: length
Accept-Language: en-us
Accept-Encoding: gzip, deflate
Connection: Keep-Alive

licenseID=string&content=string&/paramsXML=string"
					# TODO: Do actual testing pls
					#job = HTTPRespondJob.new(StringIO.new(request))
					#response = job.job_task
					#expect(response).to be_kind_of(HTTPResponse)
					#expect(job.http_request.method).to eq("POST")
					#expect(job.http_request.path).to eq("/cgi-bin/process.cgi")
					#expect(job.http_request.version).to eq("HTTP/1.1")
				end
			end
		end
	end
end