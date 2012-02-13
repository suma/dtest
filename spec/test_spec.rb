require File.expand_path(File.join('.', 'spec_helper'), File.dirname(__FILE__))
include DTest

describe Global::Manager, 'dtest instance' do
  before do
  end
  after do
    Global::Manager.instance.clear
    Test::Manager.instance.clear
  end

  it "global context" do
    GlobalHarness do
      before do
        assert_equal(nil, @fuga)  # PASS
        @fuga = 1234
      end

      after do
        assert_equal(1234, @fuga) # PASS

        assert_equal(1235, @fuga) # FAIL
      end
    end

    TestCase "testcase" do
      beforeCase do
        # TestCase cannot access Global's instance
        assert_equal(nil, @fuga)  # PASS
      end

      afterCase do
        assert_equal(nil, @fuga)  # PASS
      end
    end

    global_report = Runner.run([])
    global_report.after_failure.failure.size.should == 1

    global_report.result.size == 1
    cresult = global_report.result.first

    cresult.before_failure.failure.size.should == 0
    cresult.after_failure.failure.size.should == 0
  end

  it "testcase context" do
    GlobalHarness do
    end

    TestCase "testcase" do

      beforeCase do
        assert_equal(nil, @hoge)  # PASS
        @hoge = 12345

      end

      afterCase do
        assert_equal(12345, @hoge)  # PASS
      end

      before do
        # test cannot access TestCase's instance
        assert_equal(nil, @hoge)  # PASS
      end

      after do
        assert_equal(nil, @hoge)  # PASS
      end

      test "test1" do
        assert_equal(nil, @hoge)  # PASS
      end
    end

    global_report = Runner.run([])

    global_report.result.size == 1
    cresult = global_report.result[0]
    cresult.before_failure.failure.size.should == 0
    cresult.after_failure.failure.size.should == 0

    cresult.result.size == 1
    cresult.passed.should == 1
    cresult.failed.should == 0
  end

  it "test context" do
    GlobalHarness do
    end

    TestCase "testcase" do
      before do
        assert_equal(nil, @test)
        @test = 54321
      end

      after do
        assert_equal(54321, @test)  # PASS
        assert_equal(true, @test)   # FAIL
      end

      test "test1" do
        assert_equal(54321, @test)  # PASS
      end

      test "test2" do
        assert_equal(false, @test)  # FAIL
      end
    end

    global_report = Runner.run([])

    global_report.result.size == 1
    cresult = global_report.result.first
    cresult.result.size == 2
    result = cresult.result
    result[0].before_failure.failure.size == 1
    result[0].after_failure.failure.size == 1
    result[0].failure.size == 0
    result[1].before_failure.failure.size == 1
    result[1].after_failure.failure.size == 1
    result[1].failure.size == 1
  end
end

describe Global::Manager, 'dtest setter/getter' do
  before do
    GlobalHarness do
      before do
        set :global_value, 54321
      end

      after do
        assert_equal(54321, global_value) # PASS
      end
    end
  end

  after do
    Global::Manager.instance.clear
    Test::Manager.instance.clear
  end

  it "testcase_to_test" do

    TestCase "testcase" do
      beforeCase do
        set :member_test, 12345
        set "member_modify", 12345
        assert_equal(12345, member_test)  # PASS
        assert_equal(12345, member_modify)# PASS
        assert_equal(54321, global_value) # PASS
      end

      afterCase do
        assert_equal(12345, member_test)  # PASS
        assert_equal(10000, member_modify)# PASS(value is changed)
        assert_equal(10000, global_value) # PASS(value is changed)
      end

      test "allow_modify_member" do
        assert_equal(12345, member_test)  # PASS
        set :member_modify, 10000
      end

      test "allow_modify_global" do
        assert_equal(54321, global_value) # PASS
        set :global_value, 10000
      end
    end

    global_report = Runner.run([])
    global_report.after_failure.failure.size.should == 0

    global_report.result.size == 1
    cresult = global_report.result.first
    cresult.before_failure.failure.size.should == 0
    cresult.result.size.should == 2
    cresult.result[0].result.should == Test::Result::PASS
    cresult.after_failure.failure.size.should == 0
  end
end


describe Global::Manager, 'test global' do
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

  it "global before/after should be executed" do
    Runner.run([])
    $call.should == [:beforeGlobal, :afterGlobal]
  end

  it "testcase, test, before/after/test should be executed case" do
    TestCase "testcase1" do
      beforeCase do
        $call << :beforeCase1
      end

      afterCase do
        $call << :afterCase1
      end

      before do
        $call << :before1
      end

      after do
        $call << :after1
      end


      test "test1" do
        $call << :test1
      end

      test "test2" do
        $call << :test2
      end
    end

    TestCase "testcase2" do
      before do
        $call << :before2
      end

      after do
        $call << :after2
      end

      test "test1" do
        $call << :test1
      end
    end

    call = [
      :beforeGlobal,

      # case: testcase1
      :beforeCase1,
        :before1,
          :test1,
        :after1,
        :before1,
          :test2,
        :after1,
      :afterCase1,

      # case: testcase1
      :before2,
        :test1,
      :after2,

      # after
      :afterGlobal,
    ]

    global_report = Runner.run([])
    $call.should == call
    global_report.result.size.should == 2
  end
end

