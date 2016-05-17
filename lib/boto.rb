require "boto/version"

module Boto
  class << self
    attr_accessor :app_class, :cache, :logger

    def root
      application && application.config.root
    end

    def application
      @application ||= (app_class.instance if app_class)
    end

    def router
      @router ||= Boto::Router.new
    end

    def groups(*groups)
      env = Boto.env
      groups.unshift(:default, env)
      groups.concat ENV["CIDER_GROUPS"].to_s.split(",")
      groups.compact!
      groups.uniq!
      groups
    end

    def env
      @_env ||= ENV["CIDER_ENV"] || ENV["APP_ENV"] || "development"
    end
  end
end
