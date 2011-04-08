

require 'dtest/core'
require 'dtest/progress'

module DTest
  class Runner
    def self.run(files)
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
