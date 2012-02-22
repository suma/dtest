require 'singleton'
require 'dtest/util'
require 'dtest/failure'
require 'dtest/progress'

module DTest
  module SharedContext
    class Manager
      include Singleton
      include Hook

      attr_reader :contexts

      def initialize
        clear
      end

      def clear
        remove_instance_var
        @contexts = {}
      end

      def has_key?(name)
        @contexts.has_key?(name)
      end

      def add(name, option, &block)
        file, line, = DTest::failure_line(caller(2).first)
        str = ["#{name} context already defined"]
        str << " in #{file}:#{line}" if file && line
        raise str.join("\n") if @contexts.has_key?(name)

        @contexts[name] = block
      end
    end # class Manager

    module SharedHolder
    end
  end # module SharedContext
end # module DTest
