
module DTest
  module Global
    class Harness
      include Hook

      attr_accessor :global
      attr_accessor :before, :after

      def initialize
        @before = []
        @after = []
      end

      def execute_after(list, context)
        begin
          exec(list, context)
        rescue StandardError, Exception => e
          # にぎりつぶす
        end
      end

      def start(testcases)
        # Progress
        context = Context.new
        Progress.setUpGlobal(testcases)

        global_result = Test::GlobalResult.new(testcases)

        @before.each {|b| b.result = global_result.before_failure }
        @after.each {|b| b.result = global_result.after_failure }

        global_result.timer {
          begin
            # execute before
            exec(@before, context)

            # execute cases
            testcases.each do |testcase|
              execute_testcase(global_result, testcase)
            end
          rescue AbortGlobal => e
            # finish
          rescue StandardError, Exception => e
            # Blockでエラー処理しているので、にぎりつぶす
          ensure
            execute_after(@after, context)
            Progress.tearDownGlobal
          end
        }

        global_result
      end

      def execute_testcase(global_result, testcase)
        begin
          # execute TestCases
          testcase.execute(global_result)
        rescue AbortTest, AbortTestCase => e
          # にぎりつぶす
        end
      end
    end # class Harness

    class Manager
      include Singleton
      attr_accessor :harness

      def initialize
        clear
      end

      def clear
        remove_instance_var
        @harness = Harness.new
      end

      def before(option = {}, &block)
        b = Block.new("before", option, &block)
        b.parent = 'Global'
        @harness.before << b
      end

      def after(option = {}, &block)
        b = Block.new("after", option, &block)
        b.parent = 'Global'
        @harness.after << b
      end
    end # class Manager
  end # module Global
end # module DTest
