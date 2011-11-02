require File.expand_path(File.join('.', 'spec_helper'), File.dirname(__FILE__))

ARGV = []
begin
  load 'dtest/command.rb'
ensure
  DTest::Global::Manager.instance.clear
  DTest::Test::Manager.instance.clear
end


