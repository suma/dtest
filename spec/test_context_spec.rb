require File.expand_path(File.join('.', 'spec_helper'), File.dirname(__FILE__))
include DTest

describe SharedContext::Manager, 'dtest define shared_context' do
  include_context 'dtest'

  it "define context" do
    SharedContext 'hello' do
    end
  end

  it "missing to define same name context" do
    SharedContext 'hello' do
    end

    lambda {
      SharedContext 'hello' do
      end
    }.should raise_error(RuntimeError)
  end
end

describe Global::Manager, 'dtest include_context' do
  include_context 'dtest'

  before do
    SharedContext 'hello' do
      def hello
        'hello'
      end
    end

    SharedContext 'world' do
      def world
        'world'
      end
    end

    SharedContext 'hello_overwrite' do
      def hello
        'hello_overwrite'
      end
    end
  end

  it "missing to include undefined context" do
    lambda {
      GlobalHarness do
        include_context 'undefined_context'
      end
    }.should raise_error(RuntimeError)
  end

  it "missing to include undefined context" do
    lambda {
      TestCase 'testcase' do
        include_context 'undefined'
      end
    }.should raise_error(RuntimeError)
  end

  it "global context" do
    GlobalHarness do
      include_context 'hello'
      before do
        assert_equal('hello', hello)
      end
      after do
        assert_equal('hello', hello)
      end
    end

    TestCase "testcase" do
      test 'context' do
        assert_equal('hello', hello)
      end
    end

    global_report = Runner.run
    global_report.after_failure.failure.size.should == 0

    global_report.result.size.should == 1
    cresult = global_report.result.first
    cresult.before_failure.failure.size.should == 0
    cresult.after_failure.failure.size.should == 0

    result = cresult.result
    result[0].before_failure.failure.size.should == 0
    result[0].after_failure.failure.size.should == 0
    result[0].failure.size.should == 0
  end

  it "testcase context" do
    TestCase "testcase" do
      include_context 'hello'
      before do
        assert_equal('hello', hello)
      end

      test 'context' do
        assert_equal('hello', hello)
      end

      after do
        assert_equal('hello', hello)
      end
    end

    global_report = Runner.run
    global_report.after_failure.failure.size.should == 0

    global_report.result.size.should == 1
    cresult = global_report.result.first
    cresult.before_failure.failure.size.should == 0
    cresult.after_failure.failure.size.should == 0

    result = cresult.result
    result[0].before_failure.failure.size.should == 0
    result[0].after_failure.failure.size.should == 0
    result[0].failure.size.should == 0
  end


  it "multi include context" do
    TestCase "testcase" do
      include_context 'hello'
      include_context 'world'

      test 'context' do
        assert_equal('hello', hello)
        assert_equal('world', world)
      end
    end

    global_report = Runner.run
    global_report.after_failure.failure.size.should == 0

    global_report.result.size.should == 1
    cresult = global_report.result.first
    cresult.before_failure.failure.size.should == 0
    cresult.after_failure.failure.size.should == 0

    result = cresult.result
    result[0].before_failure.failure.size.should == 0
    result[0].after_failure.failure.size.should == 0
    result[0].failure.size.should == 0
  end


  it "multi include and overwrite context" do
    GlobalHarness do
      include_context 'hello'
      before do
        assert_equal('hello', hello)
      end
    end
    TestCase "testcase" do
      include_context 'hello_overwrite'
      test 'context' do
        assert_equal('hello_overwrite', hello)
      end
    end

    global_report = Runner.run
    global_report.after_failure.failure.size.should == 0

    global_report.result.size.should == 1
    cresult = global_report.result.first
    cresult.before_failure.failure.size.should == 0
    cresult.after_failure.failure.size.should == 0

    result = cresult.result
    result[0].before_failure.failure.size.should == 0
    result[0].after_failure.failure.size.should == 0
    result[0].failure.size.should == 0
  end

  it "context can use dtest methods" do
    SharedContext 'set' do
      set :value, 'world'

      def call_set(name, param)
        set name, param # dtest
      end

      def my_assert_equal(a, b)
        assert_equal(a, b)
      end
    end

    GlobalHarness do
      include_context 'set'
    end

    TestCase "context method" do
      before do
        call_set(:variable, 'hogehoge')
      end

      test 'context' do
        assert_equal('world', value)
        assert_equal('hogehoge', variable)
        my_assert_equal(1234, 1234)
      end
    end

    global_report = Runner.run
    global_report.after_failure.failure.size.should == 0

    global_report.result.size.should == 1
    cresult = global_report.result.first
    cresult.before_failure.failure.size.should == 0
    cresult.after_failure.failure.size.should == 0

    result = cresult.result
    result[0].before_failure.failure.size.should == 0
    result[0].after_failure.failure.size.should == 0
    result[0].failure.size.should == 0
  end
end
