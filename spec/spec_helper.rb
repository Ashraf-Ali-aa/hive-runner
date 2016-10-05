require 'rspec'

if ENV['CI']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
else
  require 'simplecov'
  SimpleCov.start
end

ENV['HIVE_ENVIRONMENT'] ||= 'test'
ENV['HIVE_CONFIG'] = File.expand_path('../configs', __FILE__)
$LOAD_PATH << File.expand_path('../../lib', __FILE__)
$LOAD_PATH << File.expand_path('../helper_lib', __FILE__)

require 'hive'

SPEC_ROOT = File.expand_path('..', __FILE__)
