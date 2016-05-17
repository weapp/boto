ARGV << '--help' if ARGV.empty?

aliases = {
  "c"  => "console",
  "s"  => "server",
}

command = ARGV.shift
command = aliases[command] || command

require 'boto/commands/tasks'

Boto::Commands::Tasks.new(ARGV).run_command!(command)
