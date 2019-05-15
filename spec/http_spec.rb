require_relative 'spec_helper'
module ROM
	module HTTP

		EOH = "\r\n\r\n"
		CONTENT = '{ "value": "asdf" }'
		POST_REQUEST = "POST / HTTP/1.1
          User-Agent: Mozilla/4.0 (compatible; MSIE5.01; Windows NT)
          Host: www.tutorialspoint.com
          Content-Type: application/json
          Content-Length: #{CONTENT.length}
          Connection: Keep-Alive#{EOH}#{CONTENT}"

		GET_REQUEST = "GET / HTTP/1.1
          User-Agent: Mozilla/4.0 (compatible; MSIE5.01; Windows NT)
          Host: www.tutorialspoint.com
          Connection: Keep-Alive#{EOH}"

        PUT_REQUEST = "PUT / HTTP/1.1
          User-Agent: Mozilla/4.0 (compatible; MSIE5.01; Windows NT)
          Host: www.tutorialspoint.com
          Content-Type: application/json
          Content-Length: #{CONTENT.length}
          Connection: Keep-Alive#{EOH}#{CONTENT}"

        DELETE_REQUEST = "DELETE / HTTP/1.1
          User-Agent: Mozilla/4.0 (compatible; MSIE5.01; Windows NT)
          Host: www.tutorialspoint.com
          Connection: Keep-Alive#{EOH}"

		describe HTTPRequest do
			it 'should create a class instance encapsulating the request' do


          http_request = HTTPRequest.new(StringIO.new(POST_REQUEST))
          expect(http_request.method).to eq("POST")
          expect(http_request.path).to eq("/")
          expect(http_request.version).to eq("HTTP/1.1")
          expect(http_request[:content_type]).to eq("application/json")
			end
		end

		describe HTTPResponse do
			it 'should create a class instance encapsulating the response' do
				http_response = HTTPResponse.new(ROM::HTTP::StatusCode::OK)
				expect(http_response.code).to eq(StatusCode::OK)
				expect(http_response[:content_length]).to eq(0)
				expect(http_response[:server]).to eq("Ruby on Mails v#{ROM::VERSION}")
			end
		end

		describe HTTPAPIResolver do

			module TestAPI

			class TestModel < Model
				property :value, String, "test"
			end

			class Static < StaticResource
				action :create, TestModel, :val! => TestModel do |val|
					next TestModel.new(:value => val.to_s)
				end

				action :fetch, TestModel do 
					next TestModel.new
				end

				action :delete, TestModel do 
					next TestModel.new(:value => "deleted")
				end

				action :update, TestModel do 
					next TestModel.new(:value => "updated")
				end

			end
		end

			before(:each) do
				@itc = Interconnect.new
				@itc.register(ApiGateway)
				@itc.load(ROM::DataSerializers)
				@itc.load(ROM::HTTP::Methods)
				@itc.load(TestAPI)
			end

			it 'should resolve GET' do
				resolver = HTTPAPIResolver.new(@itc)
				http_request = HTTPRequest.new(StringIO.new(GET_REQUEST))
				http_response = resolver.resolve(http_request)
				expect(http_response.code).to eq(StatusCode::OK)
			end

			it 'should resolve PUT' do
				resolver = HTTPAPIResolver.new(@itc)
				http_request = HTTPRequest.new(StringIO.new(PUT_REQUEST))
				http_response = resolver.resolve(http_request)
				expect(http_response.code).to eq(StatusCode::OK)
			end

			it 'should resolve POST' do
				resolver = HTTPAPIResolver.new(@itc)
				http_request = HTTPRequest.new(StringIO.new(POST_REQUEST))
				http_response = resolver.resolve(http_request)
				expect(http_response.code).to eq(StatusCode::CREATED)
			end

			it 'should resolve DELETE' do
				resolver = HTTPAPIResolver.new(@itc)
				http_request = HTTPRequest.new(StringIO.new(DELETE_REQUEST))
				http_response = resolver.resolve(http_request)
				expect(http_response.code).to eq(StatusCode::NO_CONTENT)
			end
		end

	end
end
