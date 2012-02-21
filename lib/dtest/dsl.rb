require 'dtest/test'
require 'dtest/global'
require 'dtest/failure'
require 'dtest/shared_context'

module DTest
  module DSL
    def TestCase(name, options = {}, &block)
      manager = Test::Manager::instance
      manager.instance_eval(&block)
      manager.add(name)
    end

    def GlobalHarness(&block)
      manager = Global::Manager::instance
      if manager.defined
        file, line, = DTest::failure_line(caller(1).first)
        str = ['GlobalHarness can only be only defined once.']
        str << " error at #{file}:#{line}" if file && line
        raise str.join("\n")
      else
        manager.instance_eval(&block)
        manager.defined = true
      end
    end

    def SharedContext(name, option = {}, &block)
      manager = SharedContext::Manager::instance
      manager.add(name, option, &block)
    end
  end # module DSL
end # module DTest

include DTest::DSL
