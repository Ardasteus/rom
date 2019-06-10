require_relative 'spec_helper'

module ROM
	describe Resource do
		describe '#action' do
			TOKEN = '...'

			class TestResource < Resource
				action :execute, String do
					return TOKEN
				end

				action :advanced, String, DefaultAction[], :req! => Types::Boolean[], :def => { :type => String, :default => TOKEN } do |rq, df|
					return [rq, df].inspect
				end
			end

			it 'defines actions' do
				expect(TestResource[:execute]).not_to eq nil
				expect(TestResource[:other]).to eq nil
				expect(TestResource.actions).to include(TestResource[:advanced], TestResource[:execute])
				expect(TestResource.default).to be TestResource[:advanced]
				adv = TestResource[:advanced]
				expect(adv.name).to eq 'advanced'
				expect(adv.parent).to eq TestResource
				expect(adv.attribute?(DefaultAction)).to eq true
				expect(adv.attribute(DefaultAction)).to be_kind_of DefaultAction
				sig = adv.signature
				expect(sig.return_type.accepts(String)).to eq true
				expect(sig.arguments).to include(:req, :def)
				expect(sig[:req]).not_to eq nil
				expect(sig[:def]).not_to eq nil
				expect(sig[:other]).to eq nil
				expect(sig[:req][:required]).to eq true
				expect(sig[:req][:order]).to eq 0
				expect(sig[:def][:required]).to eq false
				expect(sig[:def][:order]).to eq 1
				expect(sig[:def][:default]).to eq TOKEN
				expect(sig[0]).to eq sig[:req]
				expect(sig[1]).to eq sig[:def]
			end
		end
	end
end