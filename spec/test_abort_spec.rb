require File.expand_path(File.join('.', 'spec_helper'), File.dirname(__FILE__))
include DTest
#
# グローバル、テストケース、テスト before/after
#  abortは3種類ある
#  (2*3) * 3 = 18種類テストが必要
#
# +test時のabortで3種類


describe Global::Manager, 'global abort' do
  before do
    $call = []
  end

  after do
    Global::Manager.instance.clear
    Test::Manager.instance.clear
  end

  it "global before abort_if" do
    GlobalHarness do
      before do
        $call << :beforeGlobal
        abort_if(true, "testing aborted beforeGlobal")
        $call << :not_executed
      end

      after do
        $call << :afterGlobal
      end
    end

    TestCase "testcase1" do
      test "test1" do
        $call << :test_not_executed
      end
    end

    Runner.run([])
    $call.should == [
      :beforeGlobal,
      :afterGlobal
    ]
  end

  it "global before abort_case_if" do
    GlobalHarness do
      before do
        $call << :beforeGlobal
        abort_case_if(true, "testing aborted beforeGlobal")
        $call << :not_executed
      end

      after do
        $call << :afterGlobal
      end
    end

    TestCase "testcase1" do
      test "test1" do
        $call << :test_not_executed
      end
    end

    Runner.run([])
    $call.should == [
      :beforeGlobal,
      :afterGlobal
    ]
  end

  it "global before abort_global_if" do
    GlobalHarness do
      before do
        $call << :beforeGlobal
        abort_global_if(true, "testing aborted beforeGlobal")
        $call << :not_executed
      end

      after do
        $call << :afterGlobal
      end
    end

    TestCase "testcase1" do
      test "test1" do
        $call << :test_not_executed
      end
    end

    Runner.run([])
    $call.should == [
      :beforeGlobal,
      :afterGlobal
    ]
  end

end

describe Global::Manager, 'testcase abort' do
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

  # before: abort_if, abort_case_if, abort_global_if
  it "beforeCase abort_if" do
    TestCase "testcase1" do
      beforeCase do
        $call << :beforeCase
        abort_if(true, "testcase:before abort")
      end
      afterCase do
        $call << :afterCase
      end
      before do
        $call << :before
      end
      after do
        $call << :after
      end

      test "test1" do
        $call << :test1_not_executed
      end

      test "test2" do
        $call << :test2_not_executed
      end
    end

    TestCase "testcase2" do
      test "test1" do
        $call << :test2
      end
      test "test2" do
        $call << :test2
      end
    end

    call = [
      :beforeGlobal,
        :beforeCase,
        :afterCase,

        :test2,
        :test2,
      :afterGlobal,
    ]

    Runner.run([])
    $call.should == call
  end

  it "testcase:before abort_case_if" do
    TestCase "testcase1" do
      beforeCase do
        $call << :beforeCase
        abort_case_if(true, "testcase:before abort")
      end
      afterCase do
        $call << :afterCase
      end
      before do
        $call << :before
      end
      after do
        $call << :after
      end
      test "test1" do
        $call << :not_executed
      end
    end

    TestCase "testcase2" do
      test "test1" do
        $call << :test2
      end
    end

    call = [
      :beforeGlobal,
        :beforeCase,
        :afterCase,

        :test2,
      :afterGlobal,
    ]

    Runner.run([])
    $call.should == call
  end

  it "testcase:before abort_global_if" do
    TestCase "testcase1" do
      beforeCase do
        $call << :beforeCase
        abort_global_if(true, "testcase:before abort")
      end
      afterCase do
        $call << :afterCase
      end
      before do
        $call << :before
      end
      after do
        $call << :after
      end
      test "test1" do
        $call << :not_executed
      end
    end

    TestCase "testcase2" do
      test "test1" do
        $call << :test2
      end
    end

    call = [
      :beforeGlobal,
        :beforeCase,
        :afterCase,
      :afterGlobal,
    ]

    Runner.run([])
    $call.should == call
  end


  # after: abort_if, abort_case_if, abort_global_if
  it "testcase:after abort_if" do
    TestCase "abortcase1" do
      beforeCase do
        $call << :beforeCase
      end
      afterCase do
        $call << :afterCase
        abort_if(true, "after abort")
      end
      before do
        $call << :before
      end
      after do
        $call << :after
      end

      test "test1" do
        $call << :test1
      end

      test "test2" do
        $call << :test2
      end
    end

    TestCase "testcase2" do
      test "test1" do
        $call << :testcase2
      end
    end

    call = [
      :beforeGlobal,
        :beforeCase,
          :before,
            :test1,
          :after,
          :before,
            :test2,
          :after,
        :afterCase,

        :testcase2,

      :afterGlobal,
    ]

    Runner.run([])
    $call.should == call
  end

  it "testcase:after abort_global_if" do
    TestCase "AbortTest" do
      beforeCase do
        $call << :beforeCase
      end
      afterCase do
        $call << :afterCase
        abort_global_if(true, "testcase:before abort")
      end
      before do
        $call << :before
      end
      after do
        $call << :after
      end

      test "test1" do
        $call << :test1
      end
    end

    TestCase "AbortTest_not" do
      test "test1" do
        $call << :not_executed
      end
    end

    call = [
      :beforeGlobal,
        :beforeCase,
          :before,
            :test1,
          :after,
        :afterCase,
      :afterGlobal,
    ]

    Runner.run([])
    $call.should == call
  end

  it "testcase:after abort_case_if" do
    TestCase "abortcase1" do
      beforeCase do
        $call << :beforeCase
      end
      afterCase do
        $call << :afterCase
        abort_case_if(true, "after abort")
      end
      before do
        $call << :before
      end
      after do
        $call << :after
      end

      test "test1" do
        $call << :test1
      end
    end

    TestCase "testcase2" do
      test "test1" do
        $call << :testcase2
      end
    end

    call = [
      :beforeGlobal,
        :beforeCase,
          :before,
            :test1,
          :after,
        :afterCase,

        :testcase2,

      :afterGlobal,
    ]

    Runner.run([])
    $call.should == call
  end

  it "testcase:after abort_global_if" do
    TestCase "AbortTest" do
      beforeCase do
        $call << :beforeCase
      end
      afterCase do
        $call << :afterCase
        abort_global_if(true, "testcase:before abort")
      end
      before do
        $call << :before
      end
      after do
        $call << :after
      end

      test "test1" do
        $call << :test1
      end
    end

    TestCase "AbortTest_not" do
      test "test1" do
        $call << :not_executed
      end
    end

    call = [
      :beforeGlobal,
        :beforeCase,
          :before,
            :test1,
          :after,
        :afterCase,
      :afterGlobal,
    ]

    Runner.run([])
    $call.should == call
  end
end


describe Global::Manager, 'test abort' do
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


  it "test:after abort_if" do
    TestCase "abortcase1" do
      beforeCase do
        $call << :beforeCase
      end
      afterCase do
        $call << :afterCase
      end
      before do
        $call << :before
      end
      after do
        $call << :after
        abort_if(true, "after abort")
      end

      test "test1" do
        $call << :test1
      end

      test "test2" do
        $call << :test2
      end
    end

    TestCase "testcase2" do
      test "test1" do
        $call << :testcase2
      end
    end

    call = [
      :beforeGlobal,
        :beforeCase,
          :before,
            :test1,
          :after,
          :before,
            :test2,
          :after,
        :afterCase,

        :testcase2,
      :afterGlobal,
    ]

    Runner.run([])
    $call.should == call
  end

  it "test:after abort_case_if" do
    TestCase "abortcase1" do
      beforeCase do
        $call << :beforeCase
      end
      afterCase do
        $call << :afterCase
      end
      before do
        $call << :before
      end
      after do
        $call << :after
        abort_case_if(true, "after abort")
      end

      test "test1" do
        $call << :test1
      end

      test "test2" do
        $call << :test2
      end
    end

    TestCase "testcase2" do
      test "test1" do
        $call << :testcase2
      end
    end

    call = [
      :beforeGlobal,
        :beforeCase,
          :before,
            :test1,
          :after,
        :afterCase,

        :testcase2,
      :afterGlobal,
    ]

    Runner.run([])
    $call.should == call
  end


  it "test:after abort_global_if" do
    TestCase "AbortTest" do
      beforeCase do
        $call << :beforeCase
      end
      afterCase do
        $call << :afterCase
      end
      before do
        $call << :before
      end
      after do
        $call << :after
        abort_global_if(true, "testcase:before abort")
      end

      test "test1" do
        $call << :test1
      end

      test "test2" do
        $call << :test2_not_executed
      end
    end

    TestCase "AbortTest_not" do
      test "test1" do
        $call << :not_executed
      end
    end

    call = [
      :beforeGlobal,
        :beforeCase,
          :before,
            :test1,
          :after,
        :afterCase,
      :afterGlobal,
    ]

    Runner.run([])
    $call.should == call
  end
end



describe Global::Manager, 'test abort' do
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

  it "test abort_if" do
    TestCase "testcase1" do

      before do
        $call << :before
      end

      after do
        $call << :after
      end

      test "abort test" do
        $call << :test1
        abort_if(true, "testing abort: abort_if")
        $call << :not_executed
      end

      test "" "test2" do
        $call << :test2
      end

    end

    TestCase "testcase" do
      test "test1" do
        $call << :testcase2
      end
    end

    call = [
      :beforeGlobal,

        :before,
          :test1,
        :after,

        :before,
          :test2,
        :after,

        :testcase2,

      :afterGlobal,
    ]

    Runner.run([])
    $call.should == call
  end

  it "abort_case_if" do
    TestCase "testcase1" do
      before do
        $call << :before
      end

      after do
        $call << :after
      end

      test "test1" do
        $call << :test1
      end

      test "test2" do
        $call << :test2
        abort_case_if(true, "testing abort: abort_case_if")
      end

      test "test3" do
        $call << :test3_not_executed
      end
    end

    TestCase "testcase" do
      test "test1" do
        $call << :testcase2
      end
    end

    call = [
      :beforeGlobal,

        :before,
          :test1,
        :after,

        :before,
          :test2,
        :after,

        :testcase2,

      :afterGlobal,
    ]

    Runner.run([])
    $call.should == call
  end

  it "test abort_global_if" do
    TestCase "GlobalAbort test" do
      beforeCase do
        $call << :beforeCase
      end

      afterCase do
        $call << :afterCase
      end

      before do
        $call << :before
      end

      after do
        $call << :after
      end

      test "test" do
        $call << :test1
      end

      test "abort_global_if" do
        $call << :abort_global
        abort_global_if(true, "testing abort: abort_global_if")
      end

      test "not executed" do
        $call << :not_executed
      end

    end

    TestCase "NotExecuted" do
      test "not executed" do
        $call << :not_executed
      end

    end

    call = [
      :beforeGlobal,

        :beforeCase,
          :before,
            :test1,
          :after,
          :before,
            :abort_global,
          :after,
        :afterCase,

      :afterGlobal,
    ]

    Runner.run([])
    $call.should == call
  end

end

