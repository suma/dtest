
require 'optparse'
require 'dtest/runner'
require 'dtest/dsl'

def usage
  puts 'dtest [options] [files...]'
  puts 'dtest [options] [files...] -- [arguments for testcode]'
  puts ''
  puts '  --xml output_path   Specify path to write junit style xml.'
  puts '  --color             Enables to print color on the terminal.'
end


# Command line parser
argv = ARGV
first = ARGV.index('--')
unless first.nil?
  argv = ARGV[0..first-1]
  ARGV.slice!(0..first)
end

begin
  option = DTest::Runner.parse!(argv)
rescue OptionParser::InvalidOption => e
  puts "#{e.message}\n\n"
  usage
  exit(-1)
end

if argv.empty?
  usage
  exit(0)
end

# execute test
res = DTest::Runner.run(argv)
DTest::Runner.report(res)

# output xml
if option[:xml_path]
  res.outputxml(option[:xml_path])
end
