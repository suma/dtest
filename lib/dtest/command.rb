
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
  xml_path = nil
  opt = OptionParser.new
  opt.on('--color') do |b|
    DTest::Report.color_enabled = b
  end
  opt.on('--xml PATH') do |path|
    xml_path = path
  end
  opt.parse!(ARGV)

  # execute test
  res = DTest::Runner.run(ARGV)
  DTest::Runner.report(res)

  # output xml
  if xml_path
    res.outputxml(xml_path)
  end
end

