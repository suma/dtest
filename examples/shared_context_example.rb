SharedContext 'context1' do
  @test = 'hoge'
  set :var, 'variable1'
  def context_method
    'hello'
  end
end

SharedContext 'context2' do
  set :var, 'variable2'
  def context_method
    'world'
  end
end

GlobalHarness do
  include_context 'context1'
  before do
    assert_equal('hello', context_method)
    assert_equal('variable1', var)
    assert_equal('hoge', @test)
  end
end

TestCase 'test' do
  include_context 'context2'
  before do
    assert_equal('hoge', @test)
    @test = 'fuga'
  end
  test 'test' do
    assert_equal('world', context_method)
    assert_equal('variable2', var)
    assert_equal('fuga', @test)
  end
end
