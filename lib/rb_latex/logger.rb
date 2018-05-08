require 'logger'

module RbLatex
  class Logger < ::Logger
    def initialize(logdev = STDERR, *args, **kargs)
      super
      if !kargs[:formatter]
        self.formatter = proc do |severity, _time, _progname, message|
          "#{datetime}: #{message}\n"
        end
      end
    end

    def self.logger
      @logger ||= self::Logger.new
    end

    def self.logger=(logger)
      @logger = logger
    end
  end
end
