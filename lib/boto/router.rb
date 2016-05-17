module Boto
  class Router
    def proccess_message(env)
      listeners.each do |_desc, condition, method|
        next unless condition.call(env)
        if method.respond_to?(:call)
          method.call(env)
        elsif method.to_s.include? "#"
          klass, method = method.to_s.split("#", 2)
          instance = Math.const_get(klass).new(env)
          instance.public_send(method)
        end
      end
    end

    def listeners
      @listeners ||= []
    end

    def listen(matcher, params = {})
      method = params.fetch(:to, matcher)
      listeners << [matcher, matcher_to_proc(matcher), method]
    end

    def draw(&block)
      instance_exec(&block)
    end

    def matcher_to_proc(matcher)
      return -> (_update) { true } if matcher == :default
      return matcher if matcher.respond_to?(:call)
      return -> (update) { matcher =~ update[:text].to_s } if matcher.is_a?(Regexp)
      matcher_to_proc(%r{^/?(#{matcher})([\s@]|$)}i)
    end
  end
end
