require 'optparse'
require 'dtest/runner'
require 'dtest/dsl'

# Command line parser
argv = ARGV
first = ARGV.index('--')
unless first.nil?
  argv = ARGV[0..first-1]
  ARGV.slice!(0..first)
end
optparse, option = DTest::Runner.parse!(argv)

if argv.empty? && !option[:print]
  puts optparse
elsif !option[:print]
  # execute test
  res = DTest::Runner.run(argv)
  DTest::Runner.report(res)

  # output xml
  if option[:xml_path]
    res.outputxml(option[:xml_path])
  end
end
