require "singleton"
require "ostruct"
require "dotenv"

module Boto
  class Application
    include Singleton

    class << self
      attr_accessor :called_from

      def inherited(app_class)
        Boto.app_class = app_class

        app_class.called_from = begin
          call_stack = if Kernel.respond_to?(:caller_locations)
            caller_locations.map { |l| l.absolute_path || l.path }
          else
            # Remove the line number from backtraces making sure we don't leave anything behind
            caller.map { |p| p.sub(/:\d+.*/, '') }
          end

          File.dirname(call_stack.detect { |p| p !~ %r[boto[\w.-]*/lib/boto] })
        end

        $LOAD_PATH.unshift("#{root}/lib")
        Dir["#{root}/lib/**/*.rb"].sort.each { |file| require file }
        Dotenv.load

        super
      end

      def find_root(path)
        Pathname.new(path).dirname
      end

      def config
        @config ||= OpenStruct.new(root: find_root(Boto.app_class.called_from))
      end

      def root
        config.root
      end
    end

    def config
      self.class.config
    end

    def root
      config.root
    end

    def adapter
      config.adapter
    end
  end
end
