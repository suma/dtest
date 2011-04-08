# Example for dtest description
# $ dtest sample_test.rb --color --xml output.xml

GlobalHarness do
  # describe before/after(setup and teardown) code

  before do
    @instance_var = "Hello Global!!"
  end

  after do
    assert_equal("Hello Global??", @instance_var)
    raise Exception.new("Exception abababababa")
  end
end

TestCase "testcase_name" do
  # beforeCase/afterCase called each TestCase at once
  beforeCase do
  end

  afterCase do
  end

  # before/after called each tests
  before do
  end

  after do
  end

  test "expect_test" do
    # describe assertions
    expect_equal(0,0)
    expect_equal(0,0, "you can specify to message when aborted")

    # describe expectations(don't abort)
    expect_true(true)
    expect_equal(0, 1)  # continue testing
    expect_true(false)  # continue testing

    # you can describe abort
    abort_if(true, "message")  # abort after executed expect_?? testing
  end

  test "assert_test1" do
    assert_equal(1, 1)
  end

  test "assert_test2" do
    assert_equal(1, 2)
  end

  test "assert_test3" do
    assert_true(true)
  end

  test "assert_test4" do
    assert_true(false)
  end

end


TestCase "testcase2" do

  beforeCase do
    # set value
    set :abc, 1234
    set("member", 5432)
  end

  afterCase do
    # get value(modified by test)
    assert_equal(1000, abc)     # PASS
    assert_equal(1000, member)  # FAILED
  end

  test "getter test" do
    # get value
    assert_equal(1234, abc)   # PASS
    assert_equal(5432, member)# PASS

    # modify abc
    set :abc, 1000
  end

  # value-parameterized test
  #  combine returns product of Arrays
  test "param", :params => combine([true, false], [1,2]) do
    # parameter 'param'
    assert_true(param[0] == true || param[0] == false)
    assert_true(param[1] == 1 || param[1] == 2)
  end
end


TestCase "testcase3" do
  beforeCase do
    @var = 123456
  end

  afterCase do
    assert_equal(123456, @var)
    assert_true(false)
  end

  after do
    assert_true(false)
  end

  test "name" do
    # cannot access beforeCase/afterCase instance
    assert_equal(nil, @var)
  end

  # Global Abort when assertion failed
  # specify abort scope to :assert_abort option
  #   :global, :testcase or :test
  test "assert GlobalAbort", :assert_abort => :global do
    assert_equal(1, 100)
  end
end

TestCase "testcase4" do
  test "test" do
    puts "hello"  # not execute because of testcase3 global abort
  end
end

