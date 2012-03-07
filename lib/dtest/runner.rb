require 'optparse'
require 'dtest/version'
require 'dtest/core'
require 'dtest/progress'

module DTest
  class Runner
    def self.parse!(argv)
      # Command line parser
      res = {}
      xml_path = nil
      opt = OptionParser.new
      opt.banner = <<EOS
=====================================
 ______ _______
(______|_______)          _
 _     _   _ _____  ___ _| |_
| |   | | | | ___ |/___|_   _)
| |__/ /  | | ____|___ | | |_
|_____/   |_|_____|___/   \__)  #{DTest::VERSION}
=====================================

dtest [options] [files...]
dtest [options] [files...] -- [arguments for testcode]
EOS

      opt.version = DTest::VERSION
      opt.on('--color', 'Enables to print color on the terminal') do |b|
        DTest::Report.color_enabled = b
      end
      opt.on('--xml PATH', 'Specify path to write junit style xml') do |path|
        res[:xml_path] = path
      end
      opt.on_tail('-h', '--help','Show this message') do
        puts opt
        res[:print] = true
      end
      opt.on_tail('-v', '--version', 'Show version') do
        puts opt.ver
        res[:print] = true
      end

      begin
        opt.parse!(argv)
      rescue OptionParser::InvalidOption => e
        puts "#{e.message}\n\n"
        puts optparse
      end

      [opt, res]
    end

    def self.run(files = [])
      files.each do |file|
        load file
      end

      test = Test::Manager::instance.cases
      Global::Manager::instance.harness.start(test)
    end

    def self.report(gresult)
      Progress.print_result(gresult)
    end

  end # class Runner
end # module DTest
