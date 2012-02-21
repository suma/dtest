require File.expand_path(File.join('.', 'spec_helper'), File.dirname(__FILE__))

ARGV.slice!(0..-1)
begin
  load 'dtest/command.rb'
ensure
  DTest::Global::Manager.instance.clear
  DTest::Test::Manager.instance.clear
end
