require 'syslog'

module Klogger
  class Syslog < KloggerBase

    def start_plugin
      start_syslog(@config[:ident] || 'klogger',
                   @config[:options] || ::Syslog::LOG_PID | ::Syslog::LOG_NDELAY,
                   @config[:facility] || ::Syslog::LOG_LOCAL0)
    end

    def on_event(event)
      say_event(event)
    end

    def stop_plugin
      stop_syslog
    end

    private

    def say_event(event)
      say(KloggerBase.event_to_hash(event).to_s)
    end

    def say(msg)
      ::Syslog.log(::Syslog::LOG_INFO, msg)
    end

    def start_syslog(ident, options, facility)
      ::Syslog.open(ident, options, facility)
    end

    def stop_syslog
      ::Syslog.close
    end

  end
end
