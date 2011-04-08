require 'dtest/dsl'
require 'dtest/runner'
include DTest

describe Global::Manager, 'value_parameterized' do
  before do
    $params = []
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

  it "parameter" do
    TestCase "parameter" do
      test "param", :params => combine([true, false], [1,2,3]) do
        $params << param
      end
    end

    global_report = Runner.run([])
    executed_params = [true, false].product([1,2,3])
    $params.should == executed_params
  end

  it "parameter_combine_error" do
    lambda {
      TestCase "parameter" do
        # error: combine argument must be Array
        test "param", :params => combine([true, false], [1,2,3], 1234) do
        end
      end
      Runner.run([])
    }.should raise_error(ArgumentError, 'All arguments must be Array')
  end

end
