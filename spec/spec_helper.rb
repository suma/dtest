if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end
$LOAD_PATH << File.expand_path(File.join('..', 'lib'), File.dirname(__FILE__))
require 'dtest/dsl'
require 'dtest/runner'

def dtest_clear_instance
  Global::Manager.instance.clear
  Test::Manager.instance.clear
end

shared_context 'dtest' do
  after do
    dtest_clear_instance
  end
end
