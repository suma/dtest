require 'singleton'
require 'dtest/util'
require 'dtest/progress'

module DTest
  module Global
    class Harness
      include Hook

      attr_accessor :global
      attr_accessor :before, :after
      attr_accessor :shared_contexts

      def initialize
        @before = []
        @after = []
        @shared_contexts = []
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
        global_values = Object.new
        context = Context.new(global_values)

        unless @shared_contexts.empty?
          i = DTest::SharedContext::Manager::instance
          @shared_contexts.each { |name|
            context.instance_eval(&i.contexts[name])
          }
          context
        end

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
              testcase.shared_contexts = shared_contexts
              testcase.defined_values = global_values.clone
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
      attr_accessor :defined

      def initialize
        clear
      end

      def clear
        remove_instance_var
        @harness = Harness.new
        @defined = false
      end

      def include_context(name)
        if DTest::SharedContext::Manager::instance.has_key?(name)
          @harness.shared_contexts << name unless @harness.shared_contexts.include?(name)
        else
          raise "#{name} context is not defined"
        end
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
