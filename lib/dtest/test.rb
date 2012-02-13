
require 'dtest/progress'

module DTest
  module Test
    class Case
      include Hook

      attr_accessor :name
      attr_accessor :beforeCase, :afterCase
      attr_accessor :before, :after
      attr_accessor :test
      attr_accessor :defined_values

      def initialize(name, beforeCase, afterCase, before, after, test)
        @name = name
        @beforeCase = beforeCase
        @afterCase = afterCase
        @before = before
        @after = after
        @test = test
        @defined_values = Object.new
      end

      private
      def execute_after_case(list, context)
        begin
          exec(list, context)
        rescue AbortTest, AbortTestCase
          # にぎりつぶす
        end
      end

      # execute before/after
      def execute_after(list, context)
        begin
          exec(list, context)
        rescue AbortTest
          # にぎりつぶす
        end
      end

      public
      def execute(global_result)
        # TestCase result
        caseresult = CaseResult.new(@name)
        global_result.add(caseresult)

        # set result
        @beforeCase.each {|b| b.result = caseresult.before_failure }
        @afterCase.each {|b| b.result = caseresult.after_failure }

        Progress.setUpTestCase(name, @test.size)
          executed = 0
          passed = 0
          context = Context.new(@defined_values)

          begin
            caseresult.timer {
              # execute beforeCase
              exec(@beforeCase, context)

              # execute each test
              @test.each do |test|
                executed += 1
                result = Result.new(test.name)
                caseresult.add(result)
                execute_test(result, test)
                passed += 1 if result.result == Result::PASS
              end
            } # Stopwatch::timer
          rescue AbortTestCase
            # にぎりつぶす
          ensure
            # report
            caseresult.passed = passed
            caseresult.failed = executed - passed
            caseresult.executed = executed
            caseresult.untested = @test.size - executed

            # execute afterCase
            begin
              execute_after_case(@afterCase, context)
            ensure
              # report testcase finished
              Progress.tearDownTestCase(name, executed, caseresult.elapsed)
            end
          end
      end

      def execute_test(result, test)
        Progress.test(@name, test.name)

        context = Context.new(@defined_values)

        # set result
        @before.each {|b| b.result = result.before_failure }
        @after.each {|b| b.result = result.after_failure }

        begin
          # execute before blocks
          exec(@before, context)

          # exeucte test
          result.timer {
            test.result = result
            test.call(context, name)
          }
        rescue AbortTest
          # にぎりつぶす
          #   次のテストを実行する
        rescue AbortTestCase, AbortGlobal => e
          # スルー
          raise e
        rescue StandardError, Exception => e
          # にぎりつぶす
        ensure
          begin
            execute_after(@after, context)
          ensure
            if result.failure.empty? && result.ba_empty?
              result.result = Result::PASS
              Progress.test_success(@name, test.name)
            else
              Progress.test_fail(@name, test.name)
            end
          end
        end
      end
    end # class Case

    class Manager
      include Singleton
      include Hook

      attr_accessor :cases

      def initialize
        clear
      end

      def clear
        remove_instance_var
        flush
        @cases = []
      end

      def flush
        @beforeCase = []
        @afterCase = []
        @before = []
        @after = []
        @test = []
      end

      def beforeCase(option = {}, &block)
        @beforeCase << Block.new("beforeCase", option, &block)
      end

      def afterCase(option = {}, &block)
        @afterCase << Block.new("afterCase", option, &block)
      end

      # before test
      def before(option = {}, &block)
        @before << Block.new("before", option, &block)
      end

      # after test
      def after(option = {}, &block)
        @after << Block.new("after", option, &block)
      end

      # return product or args for value-parameterized test
      def combine(*args)
        if args.all? {|x| x.is_a? Array}
          para = args.shift
          args.each do |x|
            para = para.product(x)
          end
          para.map {|x| x.flatten(1)}
        else
          raise ArgumentError, 'All arguments must be Array'
        end
      end

      def test(name, option = {}, &block)
        if option && option[:params]
          # value-parameterized test
          params = option[:params]
          count = 0
          params.each do |param|
            test = Block.new("#{name}/#{count}", option, &block)
            test.parameter = param
            @test << test
            count += 1
          end
        else
          # normal test
          @test << Block.new(name, option, &block)
        end
      end

      def add(name)
        (@beforeCase + @afterCase + @before + @after + @test).each do |block|
          block.parent = name
        end
        @cases << Case.new(name, @beforeCase, @afterCase, @before, @after, @test)
        flush
      end
    end # class Manager
  end # module Test
end # module DTest
