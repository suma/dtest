require 'dtest/failure'
require 'rexml/document'
require 'rexml/cdata'

module DTest

  module Test
    class Failure
      def initialize
        @failure = []
      end

      def <<(s)
        @failure << s
      end

      def empty?
        @failure.empty?
      end

      def failure
        @failure
      end
    end

    # before/after result
    module BAResult
    attr_accessor :before_failure, :after_failure

      def initialize
        super
        @before_failure = Failure.new
        @after_failure = Failure.new
      end

      def ba_empty?
        @before_failure.empty? && @after_failure.empty?
      end
    end  #module BAResult

    class FailureMessage
      attr_accessor :parent, :name
      attr_accessor :file, :line, :error_line

      def initialize(parent, name, message, backtrace)
        @parent = parent
        @nane = name
        @message = message

        @file, @line, @error_line = DTest::failure_line(backtrace)
      end

      def location
        if file && line
          "#{file}:#{line}\n"
        else
          ""
        end
      end

      def all
        location + @message
      end

      def print
        #str += "[#{parent}]" if parent
        #str += "  '#{name}'\n" if name
        str = @message
        str += "  Failure/Error: #{error_line}\n" if error_line
        str += "  # #{file}:#{line}\n" if file && line
        puts "#{str}\n"
      end
    end  # FailureMessage


    class Result < Failure
      include Stopwatch
      include BAResult

      PASS = 'Pass'
      FAIL = 'Fail'
      UNTEST = 'Untested'

      attr_accessor :name, :result

      def initialize(name)
        super()
        @name = name
        @result = FAIL
      end
    end # class Result

    class CaseResult
      include Stopwatch
      include BAResult

      attr_accessor :name
      attr_accessor :result
      attr_accessor :passed, :failed, :executed, :untested

      def initialize(name)
        super()
        @name = name
        @passed = 0
        @failed = 0
        @executed = 0
        @untested = 0
        # list of Result
        @result = []
      end

      def add(result)
        @result << result
      end
    end # class CaseResult

    class GlobalResult
      include Stopwatch
      include BAResult

      attr_accessor :result

      def initialize(testcases)
        super()
        @result = []
        @test_size = testcases.inject(0) { |sum, t| sum += t.test.size}
      end

      def add(res)
        @result << res
      end

      def passed
        @passed = result.inject(0) {|sum, r| sum += r.passed} unless @passed
        @passed
      end

      def failed
        @failed ||= result.inject(0) {|sum, r| sum += r.failed}
      end


      def executed
        @executed ||= result.inject(0) {|sum, r| sum += r.executed}
      end

      def untested
        @untested ||= @test_size - executed
      end

      def outputxml(output_path)
        doc = REXML::Document.new
        root = doc.add_element('testsuites', {
          'name' => 'Global',
          'tests' => executed,
          'failures' => failed,
          'errors' => 0,
          'time' => elapsed,
        })

        result.each do |result|
          suite = root.add_element('testsuite', {
            'name' => result.name,
            'tests' => result.executed,
            'failures' => result.failed,
            'errors' => 0,
            'time' => result.elapsed,
          })

          result.result.each do |t|
            test = suite.add_element('testcase', {
              'name' => t.name,
              'status' => 'run',
              'classname' => result.name,
              'time' => t.elapsed,
            })
            t.failure.each do |msg|
              failure = test.add_element('failure', {
                'type' => '',
              })
              failure.text = REXML::CData.new(msg.all)
            end
          end
        end

        if RUBY_VERSION >= '1.9.3'
          doc.write(REXML::Output.new(File.new(output_path, 'w+')))
        else
          doc.write(REXML::Output.new(File.new(output_path, 'w+'), REXML::Encoding::UTF_8))
        end
      end
    end # class GlobalResult

  end # module Test
end # module DTest
