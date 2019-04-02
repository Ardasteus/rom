# Created by Matyáš Pokorný on 2019-03-24.

require_relative 'spec_helper'

module ROM
	describe Types do
		class Lower
		end
		class Higher < Lower
		end
		
		describe Just do
			describe '#is' do
				it 'accepts exactly given type' do
					expect(Just[String].is('')).to eq true
					expect(Just[String].is(1)).to eq false
					expect(Just[String].is(nil)).to eq false
					expect(Just[Integer].is(1)).to eq true
					expect(Just[Integer].is('')).to eq false
				end
			end
			
			describe '#accepts' do
				it 'accepts exactly classes of given type' do
					expect(Just[String].accepts(String)).to eq true
					expect(Just[String].accepts(Integer)).to eq false
					expect(Just[Integer].accepts(Integer)).to eq true
				end
				
				it 'expands types' do
					expect(Just[String].accepts(Just[String])).to eq true
					expect(Just[String].accepts(Just[Integer])).to eq false
					expect(Just[Integer].accepts(Just[Integer])).to eq true
				end
				
				it 'is covariant' do
					expect(Just[Lower].accepts(Just[Higher])).to eq true
					expect(Just[Higher].accepts(Just[Lower])).to eq false
				end
			end
		end
		
		describe Union do
			describe '#is' do
				it 'accepts any of given types' do
					expect(Union[String, Integer].is('')).to eq true
					expect(Union[String, Integer].is(1)).to eq true
					expect(Union[String, Integer].is(false)).to eq false
					expect(Union[String, Integer].is({})).to eq false
				end
			end
			
			describe '#accepts' do
				it 'accepts any of given types' do
					expect(Union[String, Integer].accepts(String)).to eq true
					expect(Union[Integer, String].accepts(String)).to eq true
					expect(Union[String, Integer].accepts(Integer)).to eq true
					expect(Union[String, Integer].accepts(Boolean)).to eq false
				end
				
				it 'expands types' do
					expect(Union[Just[String], Just[Integer]].accepts(String)).to eq true
					expect(Union[Just[String], Just[Integer]].accepts(Just[String])).to eq true
					expect(Union[Just[String], Just[Integer]].accepts(Integer)).to eq true
					expect(Union[Just[String], Just[Integer]].accepts(Boolean)).to eq false
					expect(Union[Just[String], Union[Integer, Boolean]].accepts(String)).to eq true
					expect(Union[Just[String], Union[Integer, Boolean]].accepts(Integer)).to eq true
					expect(Union[Just[String], Union[Integer, Boolean]].accepts(Just[Boolean])).to eq true
					expect(Union[Just[String], Union[Integer, Boolean]].accepts(Boolean)).to eq true
					expect(Union[Just[String], Union[Integer, Boolean]].accepts(Array)).to eq false
				end
				
				it 'accepts subsets or equivalents' do
					expect(Union[String, Integer, Boolean].accepts(Union[String, Integer])).to eq true
					expect(Union[String, Integer, Boolean].accepts(Union[Boolean, Integer])).to eq true
					expect(Union[String, Integer, Boolean].accepts(Union[Boolean, String, Integer])).to eq true
					expect(Union[String, Integer, Boolean].accepts(Union[Array, Integer])).to eq false
					expect(Union[String, Integer, Boolean].accepts(Union[String, Integer, Boolean, Array])).to eq false
				end
				
				it 'is covariant' do
					expect(Union[Lower, Integer].accepts(Higher)).to eq true
					expect(Union[Higher, Integer].accepts(Lower)).to eq false
					expect(Union[Lower, Integer, Boolean].accepts(Union[Higher, Boolean])).to eq true
				end
			end
		end
		
		describe Types::Array do
			describe '#is' do
				it 'accepts array, where all items are of given type' do
					expect(Types::Array[String].is([])).to eq true
					expect(Types::Array[String].is(['aloha'])).to eq true
					expect(Types::Array[String].is([1])).to eq false
					expect(Types::Array[String].is(['aloha', 1])).to eq false
					expect(Types::Array[Integer].is([])).to eq true
					expect(Types::Array[Integer].is([1, 5])).to eq true
					expect(Types::Array[Integer].is([1, 5, nil])).to eq false
				end
			end
			
			describe '#accepts' do
				it 'accepts array of given type' do
					expect(Types::Array[String].accepts(Types::Array[String])).to eq true
					expect(Types::Array[Integer].accepts(Types::Array[String])).to eq false
					expect(Types::Array[String].accepts(String)).to eq false
					expect(Types::Array[String].accepts(Array)).to eq false
				end
				
				it 'expands types' do
					expect(Types::Array[Union[String, Integer]].accepts(Types::Array[String])).to eq true
					expect(Types::Array[Union[String, Integer]].accepts(Types::Array[Just[String]])).to eq true
					expect(Types::Array[Union[String, Integer, Boolean]].accepts(Types::Array[Union[String, Integer]])).to eq true
					expect(Types::Array[Types::Array[String]].accepts(Types::Array[Types::Array[String]])).to eq true
					expect(Types::Array[Types::Array[String]].accepts(Types::Array[String])).to eq false
				end
				
				it 'is covariant' do
					expect(Types::Array[Lower].accepts(Types::Array[Higher])).to eq true
					expect(Types::Array[Higher].accepts(Types::Array[Lower])).to eq false
				end
			end
		end
		
		describe Types::Hash do
			describe '#is' do
				it 'accepts hash, where all keys are of given type and all values are of given type' do
					expect(Types::Hash[String, Integer].is({})).to eq true
					expect(Types::Hash[String, Integer].is({ 'hello' => 5 })).to eq true
					expect(Types::Hash[String, Integer].is({ 'hello' => 5, 'world' => 18 })).to eq true
					expect(Types::Hash[String, Integer].is({ 'hello' => false })).to eq false
					expect(Types::Hash[String, Integer].is({ 5 => 5 })).to eq false
					expect(Types::Hash[String, Integer].is({ 5 => 'hello' })).to eq false
				end
			end
			
			describe '#accepts' do
				it 'accepts hash of given key and value types' do
					expect(Types::Hash[String, Integer].accepts(Types::Hash[String, Integer])).to eq true
					expect(Types::Hash[Integer, Integer].accepts(Types::Hash[Integer, Integer])).to eq true
					expect(Types::Hash[String, Integer].accepts(Types::Hash[Integer, String])).to eq false
					expect(Types::Hash[String, Integer].accepts(String)).to eq false
					expect(Types::Hash[String, Integer].accepts(Integer)).to eq false
					expect(Types::Hash[String, Integer].accepts(Hash)).to eq false
				end
				
				it 'expands types' do
					expect(Types::Hash[Union[String, Symbol], Integer].accepts(Types::Hash[String, Integer])).to eq true
					expect(Types::Hash[Union[String, Symbol], Integer].accepts(Types::Hash[Symbol, Integer])).to eq true
					expect(Types::Hash[String, Union[Integer, Symbol]].accepts(Types::Hash[String, Integer])).to eq true
					expect(Types::Hash[String, Union[Integer, Symbol]].accepts(Types::Hash[String, Symbol])).to eq true
					expect(Types::Hash[Union[String, Boolean], Union[Integer, Symbol]].accepts(Types::Hash[Boolean, Symbol])).to eq true
					expect(Types::Hash[String, Union[Integer, Symbol, Boolean]].accepts(Types::Hash[String, Union[Symbol, Integer]])).to eq true
					expect(Types::Hash[String, Union[Integer, Symbol]].accepts(Types::Hash[Symbol, Symbol])).to eq false
					expect(Types::Hash[Union[String, Symbol], Integer].accepts(Types::Hash[Symbol, String])).to eq false
				end
				
				it 'is covariant' do
					expect(Types::Hash[Lower, Integer].accepts(Types::Hash[Higher, Integer])).to eq true
					expect(Types::Hash[String, Lower].accepts(Types::Hash[String, Higher])).to eq true
					expect(Types::Hash[Higher, Integer].accepts(Types::Hash[Lower, Integer])).to eq false
					expect(Types::Hash[String, Higher].accepts(Types::Hash[String, Lower])).to eq false
				end
			end
		end
		
		describe Types::Boolean do
			it "is a union of #{true.class.name} and #{false.class.name}" do
				expect(Types::Boolean[].is(true)).to eq true
				expect(Types::Boolean[].is(false)).to eq true
				expect(Types::Boolean[].accepts(TrueClass)).to eq true
				expect(Types::Boolean[].accepts(FalseClass)).to eq true
				expect(Types::Boolean[].accepts(Union[TrueClass, FalseClass])).to eq true
				expect(Types::Boolean[].is('')).to eq false
				expect(Types::Boolean[].is(nil)).to eq false
				expect(Types::Boolean[].accepts(Integer)).to eq false
			end
		end
		
		describe Types::Maybe do
			it "is a union of the given type and #{nil.class.name}" do
				expect(Types::Maybe[String].is('hello')).to eq true
				expect(Types::Maybe[String].is(nil)).to eq true
				expect(Types::Maybe[String].accepts(String)).to eq true
				expect(Types::Maybe[String].accepts(NilClass)).to eq true
				expect(Types::Maybe[String].accepts(Union[String, NilClass])).to eq true
				expect(Types::Maybe[String].accepts(Integer)).to eq false
				expect(Types::Maybe[String].is(5)).to eq false
				expect(Types::Maybe[Integer].is(5)).to eq true
				expect(Types::Maybe[Integer].accepts(Integer)).to eq true
				expect(Types::Maybe[Integer].accepts(NilClass)).to eq true
				expect(Types::Maybe[Integer].accepts(Union[Integer, NilClass])).to eq true
				expect(Types::Maybe[Integer].accepts(String)).to eq false
				expect(Types::Maybe[Integer].is(nil)).to eq true
				expect(Types::Maybe[Integer].is('5')).to eq false
			end
		end
		
		describe '#is' do
			it 'composes' do
				expect(Types::Array[Types::Maybe[String]].is([])).to eq true
				expect(Types::Array[Types::Maybe[String]].is(['hello'])).to eq true
				expect(Types::Array[Types::Maybe[String]].is([nil])).to eq true
				expect(Types::Array[Types::Maybe[String]].is(['yo', nil])).to eq true
				expect(Types::Array[Types::Maybe[String]].is(['yo', 5])).to eq false
				expect(Types::Hash[Types::Boolean[], Types::Maybe[String]].is({})).to eq true
				expect(Types::Hash[Types::Boolean[], Types::Maybe[String]].is({ true => 'hey' })).to eq true
				expect(Types::Hash[Types::Boolean[], Types::Maybe[String]].is({ true => nil })).to eq true
				expect(Types::Hash[Types::Boolean[], Types::Maybe[String]].is({ true => nil, false => 'heck' })).to eq true
				expect(Types::Hash[Types::Boolean[], Types::Maybe[String]].is({ 5 => 'yo' })).to eq false
				expect(Types::Hash[Types::Boolean[], Types::Maybe[String]].is({ true => 5 })).to eq false
			end
		end
	end
end