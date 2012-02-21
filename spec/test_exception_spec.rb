require File.expand_path(File.join('.', 'spec_helper'), File.dirname(__FILE__))
include DTest

describe Global::Manager, 'GlobalHarness can only be defined once' do
  include_context 'dtest'
  after do
    Global::Manager.instance.clear
    Test::Manager.instance.clear
  end

  it "multiple_definition" do

    GlobalHarness do
    end
    lambda {
      GlobalHarness do
      end
    }.should raise_error(RuntimeError)

  end
end

describe Global::Manager, 'global before/after exception' do
  include_context 'dtest'
  before do
    $call = []
  end

  it "global_before" do

    GlobalHarness do
      before do
        $call << :before
        raise Exception.new("test_global_before")
        $call << :not_executed
      end
      after do
        $call << :after
      end
    end

    Runner.run([])
    $call.should == [:before, :after]
  end

  it "global_after" do
    GlobalHarness do
      before do
        $call << :before
      end
      after do
        $call << :after
        raise Exception.new("test_global_after")
        $call << :not_executed
      end
    end

    Runner.run([])
    $call.should == [:before, :after]
  end
end


describe Global::Manager, 'test before/after exception' do
  include_context 'dtest'
  before do
    $call = []
    GlobalHarness do
      before do
        $call << :beforeGlobal
      end
      after do
        $call << :afterGlobal
      end
    end
  end

  it "testcase:beforeCase" do
    TestCase "testcase1" do
      beforeCase do
        $call << :beforeCase
        raise Exception.new("test_beforeCase")
        $call << :not_executed
      end

      afterCase do
        $call << :afterCase
      end

      test "test1" do
        $call << :test_not_executed  # not_executed
      end
    end

    Runner.run([])
    $call.should == [
      :beforeGlobal,
        :beforeCase,
        :afterCase,
      :afterGlobal
    ]
  end

  it "testcase:afterCase" do
    TestCase "testcase1" do
      beforeCase do
        $call << :beforeCase
      end

      afterCase do
        $call << :afterCase
        raise Exception.new("test_afterCase")
        $call << :not_executed
      end

      test "test1" do
        $call << :test
      end
    end

    Runner.run([])
    $call.should == [
      :beforeGlobal,
        :beforeCase,
        :test,
        :afterCase,
      :afterGlobal
    ]
  end

  it "test:after" do
    TestCase "after" do
      before do
        $call << :beforeCase
      end

      after do
        $call << :afterCase
        raise Exception.new("test_after")
        $call << :not_executed
      end

      test "test1" do
        $call << :test
      end
    end

    Runner.run([])
    $call.should == [
      :beforeGlobal,
        :beforeCase,
        :test,
        :afterCase,
      :afterGlobal
    ]
  end

  it "test:before" do
    TestCase "after" do
      before do
        $call << :before
        raise Exception.new("test_before")
        $call << :not_executed
      end

      after do
        $call << :after
      end

      test "test1" do
        $call << :test_not_executed  # not_executed
      end
    end

    Runner.run([])
    $call.should == [
      :beforeGlobal,
        :before,
        :after,
      :afterGlobal
    ]
  end

end



describe Global::Manager, 'exception catch' do
  include_context 'dtest'
  before do
    $call = []

    GlobalHarness do
      before do
        $call << :beforeGlobal
      end
      after do
        $call << :afterGlobal
      end
    end
  end

  after do
    Global::Manager.instance.clear
    Test::Manager.instance.clear
  end

  it "exception caught" do
    TestCase "exception_test" do
      test "test1" do
        assert_error(IOError) do
          test = nil
          tes += "" # NoMethodError
        end
      end
    end

    Runner.run([])
    $call.should == [
      :beforeGlobal,
      :afterGlobal
    ]

  end

  it "exception none was thrown" do

    TestCase "exception_none" do
      test "test1" do
        assert_error(Exception) do
        end
      end
    end

    Runner.run([])
    $call.should == [
      :beforeGlobal,
      :afterGlobal
    ]

  end

  it "abort test" do
    TestCase "testcase1" do
      test "test1" do
        $call << :test1
        raise Exception.new("test1(assert_abort => :testcase)")
        $call << :not_executed
      end

      test "test2" do
        $call << :test2
      end
    end

    Runner.run([])
    $call.should == [
      :beforeGlobal,
        :test1,
        :test2,
      :afterGlobal
    ]
  end

  it "abort testcase" do
    TestCase "testcase1" do
      test "test1", :assert_abort => :testcase do
        $call << :test1
        raise Exception.new("test1(assert_abort => :testcase)")
      end

      test "test2" do
        $call << :test2_not_executed
      end
    end

    Runner.run([])
    $call.should == [
      :beforeGlobal,
        :test1,
      :afterGlobal
    ]
  end

  it "abort global" do
    TestCase "testcase1" do
      test "test1", :assert_abort => :global do
        $call << :test1
        raise Exception.new("test1(assert_abort => :global)")
      end

      test "test2" do
        $call << :test2_not_executed
      end
    end

    TestCase "testcase2" do
      test "test1" do
        $call << :test1_not_executed
      end
    end

    Runner.run([])
    $call.should == [
      :beforeGlobal,
        :test1,
      :afterGlobal
    ]
  end

end



