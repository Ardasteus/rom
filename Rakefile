require 'rspec/core/rake_task'
require 'yard'
require 'yard/rake/yardoc_task'
require 'inch/rake'

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new do |yard|
	yard.files = ['src/**/*.rb']
	yard.options = %w(-c)
	yard.stats_options = %w(--compact)
end

Inch::Rake::Suggest.new('inch') do |inch|
	inch.args << 'src/**/*.rb'
end

desc 'Runs the application'
task :run do
  Dir.chdir('data') do
    require File.expand_path('../bin/run.rb')
  end
end