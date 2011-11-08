
require 'optparse'
require 'dtest/runner'
require 'dtest/dsl'

def usage
  puts "dtest [files...]"
end

if ARGV.empty?
  usage
else
  # Command line parser
  option = DTest::Runner.parse!(ARGV)

  # execute test
  res = DTest::Runner.run(ARGV)
  DTest::Runner.report(res)

  # output xml
  if option[:xml_path]
    res.outputxml(option[:xml_path])
  end
end

