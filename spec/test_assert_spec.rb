require File.expand_path(File.join('.', 'spec_helper'), File.dirname(__FILE__))
include DTest

describe Global::Manager, 'test assert' do
  include_context 'dtest'

  before do
    $call = []
  end

  it "assert global before" do
    GlobalHarness do
      before do
        assert_equal(1,2)
      end

      after do
      end
    end

    TestCase "test" do
      test "empty" do
      end
    end

    global_report = Runner.run([])
    global_report.before_failure.failure.size.should == 1
    global_report.after_failure.failure.size.should == 0
  end

  it "assert global after" do
    GlobalHarness do
      before do
      end

      after do
        assert_equal(1 ,2)
      end
    end
    TestCase "test" do
      test "empty" do
      end
    end
    global_report = Runner.run([])
    global_report.before_failure.failure.size.should == 0
    global_report.after_failure.failure.size.should == 1
  end

  it "assert testcase before/after" do
    GlobalHarness do
    end
    TestCase "test" do
      beforeCase do
        assert_equal(1, 2)
      end
      afterCase do
        assert_equal(1, 2)
      end
    end
    global_report = Runner.run([])
    global_report.result.size.should == 1
    global_report.result.first.before_failure.failure.size.should == 1
    global_report.result.first.after_failure.failure.size.should == 1
  end


  it "simple assert test" do
    GlobalHarness do
    end

    TestCase "test" do
      test "assert_equal" do
        $call << :assert_equal
        assert_equal(1, 1)
        $call << :assert_equal
        assert_equal(1, 2)
        $call << :assert_equal_not_executed
      end

      test "assert_not_equal" do
        $call << :assert_not_equal
        assert_not_equal(1, 2)
        $call << :assert_not_equal
        assert_not_equal(1, 1)
        $call << :assert_equal_not_executed
      end

      test "assert_true" do
        $call << :assert_true
        assert_true(true)
        $call << :assert_true
        assert_true(false)
        $call << :assert_true_not_executed
      end

      test "assert_false" do
        $call << :assert_false
        assert_false(false)
        $call << :assert_false
        assert_false(true)
        $call << :assert_not_true_not_executed
      end


      test "assert GlobalAbort", :assert_abort => :global do
        $call << :assert_abort
        assert_equal(1, 100)
        $call << :not_executed
      end
    end

    TestCase "not executed" do
      test "not executed" do
        $call << :not_executed
      end
    end

    call = [
      :assert_equal,
      :assert_equal,

      :assert_not_equal,
      :assert_not_equal,

      :assert_true,
      :assert_true,

      :assert_false,
      :assert_false,

      :assert_abort,
    ]

    global_report = Runner.run([])
    $call.should == call
  end


end

