if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end
$LOAD_PATH << File.expand_path(File.join('..', 'lib'), File.dirname(__FILE__))
require 'dtest/dsl'
require 'dtest/runner'
