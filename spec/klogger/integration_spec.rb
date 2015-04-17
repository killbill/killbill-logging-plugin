require 'spec_helper'

class String
  def to_string
    self
  end
end

class FakeJavaTenantUserApi

  attr_accessor :per_tenant_config

  def initialize(per_tenant_config = {})
    @per_tenant_config = per_tenant_config
  end

  def get_tenant_values_for_key(key, context)
    result = @per_tenant_config[context.tenant_id.to_s]
    result ? [result] : nil
  end
end

class MockEvent
  def event_type
    'InvoiceCreationEvent'
  end

  def object_type
    'INVOICE'
  end

  def object_id
    SecureRandom.uuid
  end

  def account_id
    SecureRandom.uuid
  end

  def tenant_id
    SecureRandom.uuid
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

      @tenant_api     = FakeJavaTenantUserApi.new
      svcs            = {:tenant_user_api => @tenant_api}
      @plugin.kb_apis = Killbill::Plugin::KillbillApi.new('klogger', svcs)

      # Start the plugin here - since the config file will be deleted
      @plugin.start_plugin
    end
  end

  it "should start and stop correctly" do
    @plugin.on_event MockEvent.new
    @plugin.stop_plugin
  end
end
