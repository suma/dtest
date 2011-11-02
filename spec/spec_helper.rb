require 'simplecov'
require 'simplecov-rcov'
SimpleCov.start
$LOAD_PATH << File.expand_path(File.join('..', 'lib'), File.dirname(__FILE__))
require 'dtest/dsl'
require 'dtest/runner'
