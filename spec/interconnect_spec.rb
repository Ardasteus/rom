# Created by Matyáš Pokorný on 2019-03-20.

require_relative 'spec_helper'

module ROM
	describe Interconnect do
		module Extension
			class Right
				include Component
				
				def initialize(itc)
				end
			end
			
			class Wrong
				def self.register(irc)
				
				end
			end
			
			module Type
			
			end
			
			module Nested
				class SecondaryRight < Right
					include Type
					
					def initialize(itc)
						super(itc)
					end
				end
			end
		end
		
		describe '#load' do
			it 'searches for components in a module' do
				itc = Interconnect.new(TextLogger.new(ShortFormatter.new, StringIO.new))
				
				[Extension::Right, Extension::Nested::SecondaryRight, Extension::Wrong].each do |i|
					allow(i).to receive(:register).and_call_original
					
					if i.include?(Component)
						expect(i).to receive(:register).with(itc)
					else
						expect(i).not_to receive(:register).with(itc)
					end
				end
				
				itc.load(Extension)
			end
		end
		
		describe '#lookup' do
			it 'looks up all components of given type' do
				itc = Interconnect.new(TextLogger.new(ShortFormatter.new, StringIO.new))
				itc.load(Extension)
				expect(itc.lookup(Component)).to contain_exactly(Extension::Right, Extension::Nested::SecondaryRight)
				expect(itc.lookup(Extension::Type)).to contain_exactly(Extension::Nested::SecondaryRight)
			end
		end
	end
end