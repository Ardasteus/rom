require_relative 'spec_helper'

module ROM
	describe ApiGateway do
		module TestAPI
			TOKEN = 'Yo!'
			
			class DynamicA < Resource
				action :value, String do
					next TOKEN
				end
			end
			
			class DynamicB < Resource
				def initialize(val)
					@val = val
				end
				
				action :simpler, DynamicA do
					next DynamicA.new
				end
				
				action :value, String do
					next @val
				end
				
				action :default, String, DefaultAction[] do |path|
					next "#{@val}#{path}"
				end
			end
			
			class StaticA < StaticResource
				namespace :api, :a
				
				action :get, DynamicA do
					next DynamicA.new
				end
			end
			
			class StaticB < StaticResource
				namespace :api, :b
				
				action :get, DynamicB, :val! => String do |val|
					next DynamicB.new(val)
				end
				
				action :default, DynamicB, DefaultAction[] do |path|
					next DynamicB.new(path)
				end
			end
		end
		
		describe '#initialize' do
			before(:each) do
				@itc = Interconnect.new
				@itc.register(TestAPI::StaticA)
				@itc.register(ApiGateway)
				@api = @itc.fetch(ApiGateway)
			end
			
			it 'loads resources already present in the interconnect' do
				expect(@api.resolve(%w(api a get))).not_to be_nil
				expect(@api.resolve(%w(api b get))).to be_nil
			end
			
			it 'sets up a hook in the interconnect for resources' do
				expect(@api.resolve(%w(api b get))).to be_nil
				@itc.register(TestAPI::StaticB)
				expect(@api.resolve(%w(api b get))).not_to be_nil
			end
		end
		
		describe '#plan' do
			before(:each) do
				@itc = Interconnect.new
				@itc.load(TestAPI)
				@itc.register(ApiGateway)
				@api = @itc.fetch(ApiGateway)
			end
			
			it 'plans the execution of a call' do
				plan = @api.plan('api', 'a', 'get')
				expect(plan).not_to be_nil
				expect(plan.length).to eq 1
				expect(plan.signature.return_type.accepts(TestAPI::DynamicA)).to eq true
				expect(plan.signature.arguments.length).to eq 0
				
				plan = @api.plan('api', 'a', 'get', 'value')
				expect(plan).not_to be_nil
				expect(plan.length).to eq 2
				expect(plan.signature.return_type.accepts(String)).to eq true
				expect(plan.signature.arguments.length).to eq 0
				
				plan = @api.plan('api', 'b', 'get', 'simpler', 'value')
				expect(plan).not_to be_nil
				expect(plan.length).to eq 3
				expect(plan.signature.return_type.accepts(String)).to eq true
				expect(plan.signature.arguments.length).to eq 1
				val = plan.signature[:val]
				expect(val).not_to be_nil
				expect(val[:order]).to eq 0
				expect(val[:type].accepts(String)).to eq true
				expect(val[:required]).to eq true
			end
			
			it 'respects default routes' do
				plan = @api.plan('api', 'b', TestAPI::TOKEN, 'value')
				expect(plan).not_to be_nil
				expect(plan.length).to eq 2
				expect(plan.signature.return_type.accepts(String)).to eq true
				expect(plan.signature.arguments.length).to eq 0
				
				plan = @api.plan('api', 'b', 'get', 'coco')
				expect(plan).not_to be_nil
				expect(plan.length).to eq 2
				expect(plan.signature.return_type.accepts(String)).to eq true
				expect(plan.signature.arguments.length).to eq 1
				val = plan.signature[:val]
				expect(val).not_to be_nil
				expect(val[:order]).to eq 0
				expect(val[:type].accepts(String)).to eq true
				expect(val[:required]).to eq true
				
				plan = @api.plan('api', 'b', TestAPI::TOKEN, 'coco')
				expect(plan).not_to be_nil
				expect(plan.length).to eq 2
				expect(plan.signature.return_type.accepts(String)).to eq true
				expect(plan.signature.arguments.length).to eq 0
			end
		end
		
		describe '#resolve' do
			before(:each) do
				@itc = Interconnect.new
				@itc.load(TestAPI)
				@itc.register(ApiGateway)
				@api = @itc.fetch(ApiGateway)
			end
			
			def check_a(action)
				expect(action).to be_a ResourceAction
				expect(action.name).to eq 'get'
				expect(action.signature.arguments.length).to eq 0
				expect(action.signature.return_type.accepts(TestAPI::DynamicA)).to eq true
				expect(action.attributes.length).to eq 0
			end
			
			def check_b(action)
				expect(action).to be_a ResourceAction
				expect(action.name).to eq 'default'
				expect(action.signature.arguments.length).to eq 0
				expect(action.signature.return_type.accepts(TestAPI::DynamicB)).to eq true
				expect(action.attributes.length).to eq 1
				expect(action.attributes[0]).to be_a DefaultAction
			end
			
			it 'gets an action' do
				check_a(@api.resolve(%w(api a get)))
			end
			
			it 'respects default routes' do
				check_b(@api.resolve(['api', 'b', TestAPI::TOKEN]))
				
			end
			
			it 'can be used relatively' do
				check_a(@api.resolve(['get'], TestAPI::StaticA))
				check_b(@api.resolve([TestAPI::TOKEN], TestAPI::StaticB))
			end
		end
	end
end