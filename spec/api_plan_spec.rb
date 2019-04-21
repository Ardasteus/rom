# Created by Matyáš Pokorný on 2019-04-19.

require_relative 'spec_helper'

module ROM
	describe ApiGateway::ApiPlan do
		module TestAPI
			class Dynamic < Resource
				def initialize(val)
					@val = val
				end
				
				action :get, String do
					next @val
				end
			end
			
			class Static < StaticResource
				action :new, Dynamic, :val! => String do |val|
					next Dynamic.new(val)
				end
				
				action :default, Dynamic, DefaultAction[] do |path|
					next Dynamic.new(path)
				end
			end
		end
		
		describe '#run' do
			before(:each) do
				@itc = Interconnect.new
				@itc.load(TestAPI)
				@itc.register(ApiGateway)
				@api = @itc.fetch(ApiGateway)
			end
			
			it 'runs the plan' do
				expect(@api.plan('new').run('value')).to be_a TestAPI::Dynamic
				expect(@api.plan('new', 'get').run('value')).to eq 'value'
				expect { @api.plan('new').run }.to raise_error
			end
			
			it 'is not affected by default routes' do
				expect(@api.plan('value', 'get').run).to eq 'value'
			end
		end
	end
end