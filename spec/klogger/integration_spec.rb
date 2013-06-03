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

  before(:each) do
    Dir.mktmpdir do |dir|
      file = File.new(File.join(dir, 'klogger.yml'), "w+")
      file.write(<<-eos)
syslog:
  :enabled: false
irc:
  :enabled: false
email:
  :enabled: false
      eos
      file.close

      @plugin = Klogger::KloggerPlugin.new
      @plugin.logger = Logger.new(STDOUT)
      @plugin.conf_dir = File.dirname(file)

      # Start the plugin here - since the config file will be deleted
      @plugin.start_plugin
    end
  end

  it "should start and stop correctly" do
    @plugin.on_event MockEvent.new
    @plugin.stop_plugin
  end
end
