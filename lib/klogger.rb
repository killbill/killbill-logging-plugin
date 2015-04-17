require 'logger'
require 'pathname'
require 'psych'

require 'killbill'

require 'klogger/base'
require 'klogger/email'
require 'klogger/irc'
require 'klogger/syslog'

MODULES = {
            :irc => Klogger::IRC,
            :syslog => Klogger::Syslog,
            :email => Klogger::Email
          }

# Killbill plugin, which dispatches to all klogger modules
module Klogger
  class KloggerPlugin < Killbill::Plugin::Notification

    def initialize(*args)
      super(*args)

      @config_key_name = "PLUGIN_CONFIG_killbill-logger".to_sym
      @enabled_modules = {}
    end

    def start_plugin
      super

      @global_config = global_configuration
      @logger.info "Klogger::KloggerPlugin started"
    end

    def on_event(event)
      tenant_id = tenant(event)

      if (event.event_type == :TENANT_CONFIG_CHANGE || event.event_type == :TENANT_CONFIG_DELETION) &&
          event.meta_data.to_sym == @config_key_name
        @enabled_modules[tenant_id] = nil
      end
      configure_modules(tenant_id) if @enabled_modules[tenant_id].nil?

      dispatch_event(event, tenant_id)
    end

    def stop_plugin
      super

      @enabled_modules.keys.each { |kb_tenant_id| stop_modules(kb_tenant_id) }
      @logger.info "Klogger::KloggerPlugin stopped"
    end

    private

    def configure_modules(kb_tenant_id)
      @enabled_modules[kb_tenant_id] ||= []

      stop_modules(kb_tenant_id)

      tenant_config = @global_config.merge(tenant_configuration(kb_tenant_id))

      # Instantiate each module
      tenant_config.each do |kmodule, config|
        next unless config[:enabled]

        module_klass = MODULES[kmodule.to_sym]
        next unless module_klass

        @logger.info "Module #{module_klass} enabled for tenant #{kb_tenant_id}"
        @enabled_modules[kb_tenant_id] << module_klass.send('new', config, @logger)
      end

      start_modules(kb_tenant_id)
    end

    def tenant_configuration(kb_tenant_id)
      return {} if kb_tenant_id.nil? || kb_tenant_id == :monotenant
      context = @kb_apis.create_context(kb_tenant_id)
      values = @kb_apis.tenant_user_api.get_tenant_values_for_key(@config_key_name, context)
      values && values[0] ? Psych.load(values[0]) : {}
    end

    def global_configuration
      config_file = "#{@conf_dir}/klogger.yml"
      return {} unless Pathname.new(config_file).file?

      begin
        Psych.load_file(config_file)
      rescue
        @logger.warn "Unable to parse the config file #{config_file}"
        {}
      end
    end

    def dispatch_event(event, kb_tenant_id)
      @enabled_modules[kb_tenant_id].each do |m|
        begin
          m.on_event(event)
        rescue => e
          @logger.warn "Unable to send event to module #{m.class}: #{e.message}"
        end
      end
    end

    def start_modules(kb_tenant_id)
      @enabled_modules[kb_tenant_id].each do |m|
        begin
          m.start_plugin
        rescue => e
          @logger.warn "Unable to start module #{m.class}: #{e.message}"
        end
      end
    end

    def stop_modules(kb_tenant_id)
      @enabled_modules[kb_tenant_id].each do |m|
        begin
          m.stop_plugin
        rescue => e
          @logger.warn "Unable to stop module #{m.class}: #{e.message}"
        end
      end
      @enabled_modules[kb_tenant_id] = []
    end

    def tenant(event)
      event.tenant_id.nil? ? :monotenant : event.tenant_id
    end
  end
end
