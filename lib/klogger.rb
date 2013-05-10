require 'logger'
require 'psych'

require 'killbill'

require 'klogger/base'
require 'klogger/irc'
require 'klogger/syslog'

MODULES = {
            :irc => Klogger::IRC,
            :syslog => Klogger::Syslog
          }

# Killbill plugin, which dispatches to all klogger modules
module Klogger
  class KloggerPlugin < Killbill::Plugin::Notification

    def initialize(*args)
      super(*args)
      @enabled_modules = []
    end

    def start_plugin
      configure_modules
      @enabled_modules.each { |m| m.start_plugin rescue nil }

      super

      @logger.info "Klogger::KloggerPlugin started"
    end

    def on_event(event)
      @enabled_modules.each { |m| m.on_event(event) rescue nil }
    end

    def stop_plugin
      super
      @enabled_modules.each { |m| m.stop_plugin rescue nil }
      @logger.info "Klogger::KloggerPlugin stopped"
    end

    private

    def configure_modules
      # Parse the config file
      begin
        @config = Psych.load_file("#{@conf_dir}/klogger.yml")
      rescue Errno::ENOENT
        @logger.warn "Unable to find the config file #{@conf_dir}/klogger.yml"
        return
      end

      # Instantiate each module
      @config.each do |kmodule, config|
        next unless config[:enabled]

        module_klass = MODULES[kmodule.to_sym]
        next unless module_klass

        @logger.info "Module #{module_klass} enabled"
        @enabled_modules << module_klass.send('new', config)
      end
    end
  end
end
