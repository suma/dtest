# -*- coding: utf-8 -*-

require 'singleton'
require 'time'
require 'rexml/document'
require 'rexml/cdata'

require 'dtest/failure'
require 'dtest/util'

require 'dtest/result'
require 'dtest/test'
require 'dtest/global'


module DTest

  class Abort < Exception
  end

  class AbortTest < Abort
    def to_s
      "AbortTest #{super}"
    end
  end

  class AbortTestCase < Abort
    def to_s
      "AbortTestCase #{super}"
    end
  end

  class AbortGlobal < Abort
    def to_s
      "AbortGlobal #{super}"
    end
  end

  class Context
    def initialize(let = nil)
      # テスト記述側（ブロック）から__stateが参照されないのが前提
      @__state = {:let => let}
    end

    def call(state, block)
      @__state = @__state.merge(state)
      begin
        instance_eval(&block)
      rescue AbortTest, AbortTestCase, AbortGlobal => e
        # スルー
        raise e
      rescue StandardError, Exception => e
        # ブロック内の例外はabortとして処理する　
        catch_exception(e)
        abort_assert
      end
    end

    def set(name, val)
      return if @__state[:let] == nil

      # set variable
      @__state[:let].instance_variable_set("@#{name}", val)
      # define getter method
      @__state[:let].instance_eval <<-EOS
        def #{name}
          @#{name}
        end
      EOS
    end

    # :let value getter
    def method_missing(name, *args, &block)
      if @__state[:let] && @__state[:let].public_methods.map(&:to_sym).include?(name)
        # getter value
        @__state[:let].send(name)
      else
        super
      end
    end

    # value-parameterized test parameters
    def param
      @__state[:parameter]
    end

    # abort type when assertion failed
    def assert_failure?
      @__state[:option][:assert_abort]
    end

    public
    # expect/assert
    def expect_true(condition, message = nil)
      failed_true(message) unless condition
    end

    def expect_false(condition, message = nil)
      failed_false(message) if condition
    end

    def expect_equal(expected, actual, message = nil)
      failed_equal(expected, actual, message) unless expected == actual
    end

    def expect_not_equal(expected, actual, message = nil)
      failed_equal(expected, actual, message) if expected == actual
    end

    def assert_true(condition, message = nil)
      unless condition
        failed_true(message)
        abort_assert
      end
    end

    def assert_false(condition, message = nil)
      if condition
        failed_false(message)
        abort_assert
      end
    end

    def assert_equal(expected, actual, message = nil)
      unless expected == actual
        failed_equal(expected, actual, message)
        abort_assert
      end
    end

    def assert_not_equal(expected, actual, message = nil)
      if expected == actual
        failed_equal(expected, actual, message)
        abort_assert
      end
    end

    def assert_error(*errors, &block)
      begin
        block.call
      rescue *errors => actual_error
        raised_expected_error = true
      rescue RuntimeError, Exception => actual_error
        raised_expected_error = false
      else
        str = "exception expected but none was thrown\n"
        failed(str)
        return
      end

      unless raised_expected_error
        str = "exception expected #{errors.to_s} but #{actual_error.inspect}\n"
        failed(str)
      end
    end

    # abort
    def abort_if(condition, message = nil)
      if condition
        str = "Abort"
        str += ": #{message}\n" if message
        failed(str)
        raise AbortTest.new(str)
      end
    end

    def abort_case_if(condition, message = nil)
      if condition
        str = "Abort TestCase"
        str += ": #{message}\n" if message
        failed(str)
        raise AbortTestCase.new(str)
      end
    end

    def abort_global_if(condition, message = nil)
      if condition
        str = "Abort global"
        str += ": #{message}\n" if message
        failed(str)
        raise AbortGlobal.new(str)
      end
    end

    private #internal methods
    def failed_equal(expected, actual, message = nil)
      str = <<END
  expected: #{expected.inspect}
       got: #{actual.inspect}
END
      str += "#{message}\n" if message
      failed(str, 3)
    end

    def failed_true(message = nil)
      str = "condition must be true\n"
      str += "#{message}\n" if message
      failed(str, 3)
    end

    def failed_false(message = nil)
      str = "condition must be false\n"
      str += "#{message}\n" if message
      failed(str, 3)
    end

    def catch_exception(e)
      str = "Exception #{e.inspect}\n"
      add_failure(str, e.backtrace.first)
    end

    def add_failure(error, backtrace)
      if @__state[:result]
        @__state[:result] << (Test::FailureMessage.new(@__state[:parent], @__state[:name], error, backtrace))
      end
    end

    # push failure message
    def failed(error, level = 2)
      add_failure(error, caller(level).first)
    end

    def abort_assert
      case assert_failure?
      when :global
        raise AbortGlobal.new
      when :testcase
        raise AbortTestCase.new
      else
        raise AbortTest.new
      end
    end
  end # class Context


  class Block
    attr_reader :name
    attr_accessor :parent, :result, :parameter

    def initialize(name, option, &block)
      @name = name
      @parent = nil
      @option = option
      @block = block
      @result = nil # caller result object
      @parameter = nil
    end

    def call(context, name = nil)
      @parent = name if name
      context.call({
        :parent => @parent,
        :name => @name,
        :option => @option,
        :result => @result,
        :parameter => @parameter,
      }, @block)
    end

  end # class Context

end # module DTest

