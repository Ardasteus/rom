$LOAD_PATH.unshift(File.expand_path('../../src', __FILE__))
require 'simplecov'

SimpleCov.start do
  project_name 'Ruby on Mails'
  coverage_dir 'cover'
  add_group 'src', 'src'
  add_group 'spec', 'spec'
end

require 'rom'
require 'rspec'
