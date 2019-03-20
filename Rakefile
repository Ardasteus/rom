require 'rspec/core/rake_task'
require 'yard'
require 'yard/rake/yardoc_task'
require 'inch/rake'

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new do |yard|
	yard.files = ['src/**/*.rb']
end

Inch::Rake::Suggest.new('inch')
