# Example for dtest description
#  ruby sample2.rb --color
require 'rubygems'
require 'dtest'

TestCase "hello" do
  test "hello world" do
    expect_equal(0,1)
  end
end

