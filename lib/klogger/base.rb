module Klogger
  class KloggerBase

    def initialize(config, logger)
      @config = config
      @logger = logger
    end

    def self.event_to_hash(event)
      {
        :event_type => event.event_type,
        :object_type => event.object_type,
        :event_id => event.object_id,
        :account_id => event.account_id,
        :tenant_id => event.tenant_id
      }
    end

  end
end
