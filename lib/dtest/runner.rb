

require 'optparse'
require 'dtest/core'
require 'dtest/progress'

module DTest
  class Runner
    def self.parse!(argv)
      # Command line parser
      res = {}
      xml_path = nil
      opt = OptionParser.new
      opt.on('--color') do |b|
        DTest::Report.color_enabled = b
      end
      opt.on('--xml PATH') do |path|
        res[:xml_path] = path
      end
      opt.parse!(argv)

      res
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
