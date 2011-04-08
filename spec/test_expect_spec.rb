require 'dtest/dsl'
require 'dtest/runner'
include DTest


describe Global::Manager, 'execpted' do
  before do
    $call = []
  end

  after do
    Global::Manager.instance.clear
    Test::Manager.instance.clear
  end

  it "test expect_true" do
    GlobalHarness do
      before do
        expect_true(false)
        $call << :beforeGlobal
      end

      after do
        expect_true(false)
        $call << :afterGlobal
      end
    end

    TestCase "expect_true" do
      beforeCase do
        expect_true(false)
        $call << :beforeCase
      end

      afterCase do
        expect_true(false)
        $call << :afterCase
      end

      before do
        expect_true(false)
        $call << :before
      end

      after do
        expect_true(false)
        $call << :after
      end

      test "test1" do
        expect_true(false)
        $call << :test1
        expect_true(false)
        $call << :test2
      end
    end

    call = [
      :beforeGlobal,
        :beforeCase,
          :before,
            :test1,
            :test2,
          :after,
        :afterCase,
      :afterGlobal,
    ]


    Runner.run([])
    $call.should == call
  end

  it "test expect_equal" do
    GlobalHarness do
      before do
        expect_equal(true, false)
        $call << :beforeGlobal
      end

      after do
        expect_equal(true, false)
        $call << :afterGlobal
      end
    end

    TestCase "expect_equal" do
      beforeCase do
        expect_equal(true, false)
        $call << :beforeCase
      end

      afterCase do
        expect_equal(true, false)
        $call << :afterCase
      end

      before do
        expect_equal(true, false)
        $call << :before
      end

      after do
        expect_equal(true, false)
        $call << :after
      end

      test "test1" do
        expect_equal(true, false)
        $call << :test1
        expect_equal(true, false)
        $call << :test2
      end
    end

    call = [
      :beforeGlobal,
        :beforeCase,
          :before,
            :test1,
            :test2,
          :after,
        :afterCase,
      :afterGlobal,
    ]

    Runner.run([])
    $call.should == call
  end

  it "simple expect test" do

    TestCase "test" do
      before do
      end

      after do
      end

      test "expect_equal" do
        $call << :expect_equal
        expect_equal(1, 1)
        $call << :expect_equal
        expect_equal(1, 2)
        $call << :expect_equal
      end

      test "expect_not_equal" do
        $call << :expect_not_equal
        expect_not_equal(1, 2)
        $call << :expect_not_equal
        expect_not_equal(1, 1)
        $call << :expect_not_equal
      end

      test "expect_true" do
        $call << :expect_true
        expect_true(true)
        $call << :expect_true
        expect_true(false)
        $call << :expect_true
      end

      test "expect_false" do
        $call << :expect_false
        expect_false(false)
        $call << :expect_false
        expect_false(true)
        $call << :expect_false
      end

    end

    TestCase "testcase2" do
      test "test2" do
        $call << :test
      end
    end

    call = [
      :expect_equal,
      :expect_equal,
      :expect_equal,

      :expect_not_equal,
      :expect_not_equal,
      :expect_not_equal,

      :expect_true,
      :expect_true,
      :expect_true,

      :expect_false,
      :expect_false,
      :expect_false,

      :test,
    ]

    global_report = Runner.run([])
    $call.should == call
  end
end



describe Global::Manager, 'expect failure count' do
  before do
    GlobalHarness do
      before do
      end

      after do
      end
    end
  end

  after do
    Global::Manager.instance.clear
    Test::Manager.instance.clear
  end

  it "fail_before" do
    TestCase "before" do
      before do
        expect_true(false)
      end

      after do
      end

      test "test" do
      end

      test "test" do
      end
    end
    global = Runner.run([])
    global.result.size.should == 1
    result = global.result[0].result
    result.size.should == 2
    result[0].before_failure.failure.size.should == 1
    result[1].before_failure.failure.size.should == 1
    global.passed.should == 0
    global.failed.should == 2
  end

  it "fail_after" do
    TestCase "after" do
      before do
      end

      after do
        expect_true(false)
      end

      test "test" do
      end
      test "test" do
      end
    end
    global = Runner.run([])
    global.passed.should == 0
    global.failed.should == 2
  end

  it "fail_test" do
    TestCase "after" do
      before do
      end

      after do
      end

      test "test" do
        expect_true(false)
      end

      test "test" do
        expect_true(true)
      end
    end
    global = Runner.run([])
    global.passed.should == 1
    global.failed.should == 1
  end
end

