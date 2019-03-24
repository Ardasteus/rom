# Created by Matyáš Pokorný on 2019-03-24.

require_relative 'spec_helper'

module ROM
	describe Types do
		describe Just do
			it 'accepts exactly given type' do
				expect(Just[String].is('')).to eq true
				expect(Just[String].is(1)).to eq false
				expect(Just[String].is(nil)).to eq false
				expect(Just[Integer].is(1)).to eq true
				expect(Just[Integer].is('')).to eq false
			end
		end
		
		describe Union do
			it 'accepts any of given types' do
				expect(Union[String, Integer].is('')).to eq true
				expect(Union[String, Integer].is(1)).to eq true
				expect(Union[String, Integer].is(false)).to eq false
				expect(Union[String, Integer].is({})).to eq false
			end
		end
		
		describe Types::Array do
			it 'accepts array, where all items are of given type' do
				expect(Types::Array[String].is([])).to eq true
				expect(Types::Array[String].is([ 'aloha' ])).to eq true
				expect(Types::Array[String].is([ 1 ])).to eq false
				expect(Types::Array[String].is([ 'aloha', 1 ])).to eq false
				expect(Types::Array[Integer].is([])).to eq true
				expect(Types::Array[Integer].is([ 1, 5 ])).to eq true
				expect(Types::Array[Integer].is([ 1, 5, nil ])).to eq false
			end
		end
		
		describe Types::Hash do
			it 'accepts hash, where all keys are of given type and all values are of given type' do
				expect(Types::Hash[String, Integer].is({})).to eq true
				expect(Types::Hash[String, Integer].is({ 'hello' => 5 })).to eq true
				expect(Types::Hash[String, Integer].is({ 'hello' => 5, 'world' => 18 })).to eq true
				expect(Types::Hash[String, Integer].is({ 'hello' => false })).to eq false
				expect(Types::Hash[String, Integer].is({ 5 => 5 })).to eq false
				expect(Types::Hash[String, Integer].is({ 5 => 'hello' })).to eq false
			end
		end
		
		describe Types::Boolean do
		  it "accepts #{true.class.name} and #{false.class.name}" do
		    expect(Types::Boolean[].is(true)).to eq true
		    expect(Types::Boolean[].is(false)).to eq true
		    expect(Types::Boolean[].is('')).to eq false
		    expect(Types::Boolean[].is(nil)).to eq false
		  end
		end
		
		describe Types::Maybe do
			it "accepts the given type and #{nil.class.name}" do
			  expect(Types::Maybe[String].is('hello')).to eq true
			  expect(Types::Maybe[String].is(nil)).to eq true
			  expect(Types::Maybe[String].is(5)).to eq false
				expect(Types::Maybe[Integer].is(5)).to eq true
			  expect(Types::Maybe[Integer].is(nil)).to eq true
				expect(Types::Maybe[Integer].is('5')).to eq false
			end
		end
		
		it 'composes' do
		  expect(Types::Array[Types::Maybe[String]].is([])).to eq true
		  expect(Types::Array[Types::Maybe[String]].is([ 'hello' ])).to eq true
		  expect(Types::Array[Types::Maybe[String]].is([ nil ])).to eq true
		  expect(Types::Array[Types::Maybe[String]].is([ 'yo', nil ])).to eq true
		  expect(Types::Array[Types::Maybe[String]].is([ 'yo', 5 ])).to eq false
		  expect(Types::Hash[Types::Boolean[], Types::Maybe[String]].is({ })).to eq true
		  expect(Types::Hash[Types::Boolean[], Types::Maybe[String]].is({ true => 'hey' })).to eq true
		  expect(Types::Hash[Types::Boolean[], Types::Maybe[String]].is({ true => nil })).to eq true
		  expect(Types::Hash[Types::Boolean[], Types::Maybe[String]].is({ true => nil, false => 'heck' })).to eq true
		  expect(Types::Hash[Types::Boolean[], Types::Maybe[String]].is({ 5 => 'yo' })).to eq false
		  expect(Types::Hash[Types::Boolean[], Types::Maybe[String]].is({ true => 5 })).to eq false
		end
	end
end