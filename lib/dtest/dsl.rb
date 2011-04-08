
require 'dtest/core'

module DTest
  module DSL
    def TestCase(name, options = {}, &block)
      manager = Test::Manager::instance
      manager.instance_eval(&block)
      manager.add(name)
    end

    def GlobalHarness(&block)
      manager = Global::Manager::instance
      manager.instance_eval(&block)
    end
  end # module DSL
end # module DTest

include DTest::DSL
