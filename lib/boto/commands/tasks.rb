module Boto
  module Commands
    class Tasks
      COMMAND_WHITELIST = %w(console server runner new version)

      def initialize(argv)
        @args = argv
      end

      def run_command!(command)
        command = parse_command(command)

        send(command) if COMMAND_WHITELIST.include?(command)
      end

      def console
        set_application_directory!

        require APP_PATH
        Dir.chdir(Boto.application.root)

        require "pry" rescue nil
        if defined? Pry
          Pry.start
        else
          require "irb"
          IRB.start
        end
      end

      def server
        set_application_directory!
        require_command!("server")

        Boto::Server.new.tap do |server|
          # We need to require application after the server sets environment,
          # otherwise the --environment option given to the server won't propagate.
          require APP_PATH
          Dir.chdir(Boto.application.root)
          server.start
        end
      end

      def runner
      end

      def new
      end

      def version
      end

      private

      def set_application_directory!
        Dir.chdir(File.expand_path('../../', APP_PATH)) unless File.exist?(File.expand_path("config.ru"))
      end

      def require_command!(command)
        require "boto/commands/#{command}"
      end

      def parse_command(command)
        case command
        when '--version', '-v'
          'version'
        when '--help', '-h'
          'help'
        else
          command
        end
      end
    end
  end
end
