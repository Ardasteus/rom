# Created by Matyáš Pokorný on 2019-03-24.

require_relative 'spec_helper'

module ROM
	describe Model do
		class TestAttribute < Attribute
			def name
				@name
			end
			
			def initialize(name)
				@name = name
			end
		end
		
		class TestModel < Model
			property! :name, String, TestAttribute['name']
			property :x, Integer, 4
			property :y, Integer
		end
		
		describe '#initialize' do
			it 'takes values' do
				mod = TestModel.new :name => 'point', :x => 5, :y => 1
				expect(mod.name).to eq 'point'
				expect(mod.x).to eq 5
				expect(mod.y).to eq 1
			end
			
			it 'checks types' do
				expect { TestModel.new :name => 5 }.to raise_error(Model::ConversionException)
			end
			
			it 'checks existence of properties' do
				expect { TestModel.new :other => 'something.' }.to raise_error(Exception)
			end
			
			it 'sets default values' do
				mod = TestModel.new :name => 'point'
				expect(mod.x).to eq 4
				expect(mod.y).to be_nil
			end
		end
		
		describe 'property accessors' do
			before do
				@mod = TestModel.new :name => 'point'
			end
			
			it 'stores values' do
				@mod.name = 'different'
				expect(@mod.name).to eq 'different'
				@mod.x = 15
				expect(@mod.x).to eq 15
				@mod[:name] = 'different'
				expect(@mod[:name]).to eq 'different'
				@mod[:x] = 16
				expect(@mod[:x]).to eq 16
			end
			
			it 'checks types' do
				expect { @mod.x = '15' }.to raise_error(Model::ConversionException)
			end
			
			it 'check existence' do
				expect { @mod.other = 'something.' }.to raise_error(Exception)
			end
		end
		
		describe '.from_object' do
			it 'transforms objects to model instances' do
				mod = TestModel.from_object({ :name => 'point', :x => 5, :y => 1 })
				expect(mod).to be_a(TestModel)
				expect(mod.name).to eq 'point'
				expect(mod.x).to eq 5
				expect(mod.y).to eq 1
			end
			
			it "doesn't accept nonexistent properties" do
			  expect { TestModel.from_object({ :name => 'point', :x => 5, :y => 1, :other => 'something.' }) }.to raise_error(Exception)
			end
			
			it 'sets default values' do
				mod = TestModel.from_object({ :name => 'point' })
				expect(mod.x).to eq(4)
				expect(mod.y).to be_nil
			end
			
			it 'checks types' do
			  expect { TestModel.from_object({ :name => 15 }) }.to raise_error(Model::ConversionException)
			end
			
			it 'expands sub-models' do
				class Upper < Model
					class Lower < Model
						property! :value, Integer
					end
					
					property! :name, String
					property! :sub, Lower
				end
				
				mod = Upper.from_object({ :name => 'name', :sub => { :value => 5 } })
				expect(mod).to be_a(Upper)
				expect(mod.name).to eq 'name'
				expect(mod.sub).to be_a(Upper::Lower)
				expect(mod.sub.value).to eq 5
			end
		end
		
		describe '.properties' do
		  it 'contains all defined properties' do
		  	expect(TestModel.properties.any? { |i| i.name == 'name' and i.type.is('') and i.required? }).to eq(true)
				expect(TestModel.properties.any? { |i| i.name == 'x' and i.type.is(1) and not i.required? }).to eq(true)
				expect(TestModel.properties.any? { |i| i.name == 'y' and i.type.is(1) and not i.required? }).to eq(true)
				expect(TestModel.properties.first { |i| i.name == 'name' }.attribute? { |i| i.is_a?(TestAttribute) and i.name == 'name' }).to eq(true)
		  end
		end
	end
end