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

ENABLED_MODULES = []

LOG = Logger.new(STDOUT)
LOG.level = Logger::INFO

# Parse the config file
begin
  CONFIG = Psych.load_file('klogger.yml')
rescue Errno::ENOENT
  LOG.warn 'Unable to find the config file klogger.yml'
  CONFIG = {}
end

# Instantiate each module
CONFIG.each do |kmodule, config|
  next unless config['enabled']

  module_klass = MODULES[kmodule.to_sym]
  next unless module_klass

  LOG.info "Module #{module_klass} enabled"
  ENABLED_MODULES << module_klass.send('new', config)
end

# Killbill plugin, which dispatches to all klogger modules
module Klogger
  class KloggerPlugin < Killbill::Plugin::Notification

    def start_plugin
      ENABLED_MODULES.each { |m| m.start_plugin rescue nil }
      super
    end

    def on_event(event)
      ENABLED_MODULES.each { |m| m.on_event(event) rescue nil }
    end

    def stop_plugin
      super
      ENABLED_MODULES.each { |m| m.stop_plugin rescue nil }
    end

  end
end
