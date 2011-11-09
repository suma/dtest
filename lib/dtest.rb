require 'dtest/runner'
require 'dtest/dsl'

at_exit do
  # parse and run
  option = DTest::Runner.parse!(ARGV)
  res = DTest::Runner.run
  DTest::Runner.report(res)
  # output xml
  if option[:xml_path]
    res.outputxml(option[:xml_path])
  end
end

