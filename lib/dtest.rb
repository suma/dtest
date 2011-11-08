require 'dtest/runner'
require 'dtest/dsl'

at_exit do
  # parse and run
  DTest::Runner.parse!(ARGV)
  res = DTest::Runner.run
  DTest::Runner.report(res)
end

