
require 'dtest/report'

module DTest
  class Progress
    def self.test_str(test_size)
      test_str = test_size > 1 ? 'tests' : 'test'
      "#{test_size} #{test_str}"
    end

    def self.case_str(testcase_size)
      testcase_str = testcase_size > 1 ? 'cases' : 'case'
      "#{testcase_size} #{testcase_str}"
    end

    def self.error_str(size)
      str = 'error'
      str += 's' if size > 0
      "#{size} #{str}"
    end

    def self.setUpGlobal(testcase)
      test_size = testcase.inject(0) { |sum, t| sum += t.test.size}
      Report.tag :global, test_str(test_size) + " from " + case_str(testcase.size)
      Report.tag :global, "Global test environment set-up."
      puts ''
    end

    def self.tearDownGlobal
      Report.tag :global, "Global test environment tear-down."
    end

    def self.setUpTestCase(name, size)
      Report.tag :line, test_str(size) + " from #{name}"
      Report.tag :testcase, "#{name} set-up."
    end

    def self.tearDownTestCase(name, size, elapsed)
      Report.tag :testcase, "#{name} tear-down."
      Report.tag :line, test_str(size) + " executed from #{name} (#{elapsed} seconds)"
      puts ''
    end

    def self.test(casename, name)
      Report.left :run, "#{casename}.#{name}"
    end

    def self.test_success(casename, name)
      Report.right :ok, "#{casename}.#{name}"
    end

    def self.test_fail(casename, name)
      Report.right :fail, "#{casename}.#{name}"
    end

    def self.print_result(gresult)
      #  collect TestCase failures
      cases = []
      gresult.result.each do |result|
        # test
        test = []
        result.result.each do |r|
          unless r.empty? && r.ba_empty?
            test << r
          end

        end

        unless result.ba_empty? && test.empty?
          cases << {
            :case => result,
            :test => test,
          }
        end
      end

      global_failed = !gresult.ba_empty?

      #####################
      # Output error status
      split = global_failed || !cases.empty?
      Report.split if split

      # Report Global
      if global_failed
        err = []
        err << 'before' unless gresult.before_failure.empty?
        err << 'after' unless gresult.after_failure.empty?
        Report.tag :global, "Global failure"
        Report.tag :empty, "  " + err.join(', ')
      end

      # Report TestCase
      unless cases.empty?
        str = cases.inject([]) {|a, s| a << s[:case].name }.join(', ')
        Report.tag :testcase, "#{case_str(cases.size)}"
        Report.tag :empty, "  #{str}"
      end

      # Report test each cases
      cases.each do |x|
        c = x[:case]
        t = x[:test]
        err = []
        err << 'beforeCase' unless c.before_failure.empty?
        err << 'afterCase' unless c.after_failure.empty?
        err = t.inject(err) {|a, s| a << s.name }
        Report.tag :test, "#{c.name}:  #{error_str(err.size)}"
        Report.tag :empty, "  #{err.join(', ')}"
      end



      ##################
      # Output failures
      Report.split if split

      # Global before/after failure
      if global_failed
        # before
        Report.tag :fail, 'Global.before' unless gresult.before_failure.empty?
        print_failure(gresult.before_failure)

        # after
        Report.tag :fail, 'Global.after' unless gresult.after_failure.empty?
        print_failure(gresult.after_failure)
      end

      # Report testcase and test failures
      cases.each do |x|
        c = x[:case]
        casename = c.name
        #Report.tag :testcase, "#{casename}"
        # testcase before/after
        Report.tag :fail, "#{casename}.beforeCase" unless c.before_failure.empty?
        print_failure(c.before_failure)
        Report.tag :fail, "#{casename}.afterCase" unless c.after_failure.empty?
        print_failure(c.after_failure)

        # test before/test/after
        x[:test].each do |t|
          name = t.name
          Report.tag :fail, "#{casename}.#{name}.before" unless t.before_failure.empty?
          print_failure(t.before_failure)
          Report.tag :fail, "#{casename}.#{name}" unless t.failure.empty?
          print_failure(t)
          Report.tag :fail, "#{casename}.#{name}.after" unless t.after_failure.empty?
          print_failure(t.after_failure)
        end
      end

      puts ""
      puts "Finished in #{gresult.elapsed} seconds"
      puts "--------------------------------"
      Report.tag :passed, gresult.passed
      Report.tag :failed, gresult.failed
      Report.tag :tested, gresult.executed
      Report.tag :untest, gresult.untested
    end

    def self.print_failure(failure)
      failure.failure.each do |msg|
        msg.print
      end
    end
  end # class Progress
end # module DTest
