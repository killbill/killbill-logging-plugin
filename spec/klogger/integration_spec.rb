require 'spec_helper'

class String
  def to_string
    self
  end
end

class MockEvent
  def get_event_type
    'InvoiceCreationEvent'
  end

  def get_object_type
    'INVOICE'
  end

  def get_object_id
    '1234'
  end

  def get_account_id
    '11-22-33'
  end

  def get_tenant_id
    '1100-998'
  end
end

describe Klogger do

  it 'should be able to parse a config file' do
    plugin = Klogger::KloggerPlugin.new
    plugin.start_plugin
    plugin.on_event MockEvent.new
    plugin.stop_plugin
  end

end
