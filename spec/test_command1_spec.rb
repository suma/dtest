require File.expand_path(File.join('.', 'spec_helper'), File.dirname(__FILE__))

ARGV = []

Dir::glob(File.dirname(__FILE__) + "/dtest/*.rb").each {|f|
  ARGV << f
}

def exec_cmd
  begin
    load 'dtest/command.rb'
  ensure
    DTest::Global::Manager.instance.clear
    DTest::Test::Manager.instance.clear
  end
end

# execute dtest 1(without color, no output xml)
exec_cmd

# execute dtest 2(with color, output xml)
require 'tempfile'
temp = Tempfile.new('foo')
begin
  temp.close
  ARGV.insert(0, '--xml')
  ARGV.insert(1, temp.path)
  ARGV << '--color'
  exec_cmd
ensure
  temp.unlink
end

