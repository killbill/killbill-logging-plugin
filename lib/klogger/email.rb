require 'mail'

module Klogger
  class Email < KloggerBase

    def start_plugin
      configure
    end

    def on_event(event)
      say_event(event)
    end

    private

    def say_event(event)
      email_body = <<-eos
Event type: #{event.event_type}
Object type: #{event.object_type}
Account id: #{event.account_id}
Event id: #{event.object_id}
Tenant id: #{event.tenant_id}
eos
      say(event.event_type, email_body)
    end

    def say(type, msg)
      recipient = @config[:to]
      sender = @config[:from] || "ops@killbill.com"
      topic = @config[:subject] || "New Kill Bill event: #{type}"

      # Instance variables won't be visible inside the block
      email = Mail.deliver do
             to recipient
           from sender
        subject topic
           body msg
      end
      @logger.debug "Sent message #{email.message_id} to #{email.to}"
    end

    def configure
      options = { :address              => @config[:address],
                  :port                 => @config[:port],
                  :domain               => @config[:domain],
                  :user_name            => @config[:username],
                  :password             => @config[:password],
                  :authentication       => @config[:authentication],
                  :enable_starttls_auto => @config[:enable_starttls_auto] }



      specified_delivery_method = @config[:delivery_method] || :smtp
      Mail.defaults do
        delivery_method specified_delivery_method, options
      end
    end
  end
end
