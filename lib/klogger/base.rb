module Klogger
  class KloggerBase

    def initialize(config)
      @config = config
    end

    def self.event_to_hash(event)
      {
        :event_type => event.get_event_type,
        :object_type => event.get_object_type,
        :event_id => event.get_object_id.to_string,
        :account_id => event.get_account_id.to_string,
        :tenant_id => event.get_tenant_id.to_string
      }
    end

  end
end
