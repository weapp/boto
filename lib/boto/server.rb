module Boto
  class Server
    def adapter
      Boto.application.adapter
    end

    def start
      require "#{Boto.root}/config/router"
      adapter.updates.select(&:itself).each(&method(:tick!))
    end

    def tick!(update)
      p update
      Boto.router.proccess_message(update)
    end
  end
end


