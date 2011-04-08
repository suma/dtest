

module Singleton
  def remove_instance_var
    # remove all instance vars
    instance_variables.each do |name|
      remove_instance_variable(name)
    end
  end
end # module Singleton

module DTest
  module Stopwatch
    attr_accessor :start, :finish
    def timer(&block)
      begin
        @start = Time.now
        block.call
      ensure
        @finish = Time.now
      end

      def elapsed
        if @finish && @start
          sprintf('%f', (@finish - @start).to_f)
        else
          nil
        end
      end
    end
  end # class Stopwatch

  # Block executor
  module Hook
    def exec(list, context)
      list.each do |block|
        block.call(context)
      end
    end
  end

end # module DTest

