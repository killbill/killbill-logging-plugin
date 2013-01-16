require 'cinch'

module Klogger
  class IRC < KloggerBase

    def start_plugin
      @channels = @config[:channels] || ['#killbilling']
      start_bot(@config[:nick] || 'klogger',
                @config[:server] || 'irc.freenode.org',
                @config[:port] || 6667)
    end

    def on_event(event)
      @bot.handlers.dispatch(:killbill_events, nil, event, @channels)
      # Give it some time to write the event to the channel
      sleep 1
    end

    def stop_plugin
      stop_bot
    end

    private

    class KloggerIRCBot
      include Cinch::Plugin

      listen_to :killbill_events
      def listen(m, event, channels)
        say_event(event, channels)
      end

      private

      def say_event(event, channels)
        say(KloggerBase.event_to_hash(event).to_s, channels)
      end

      def say(msg, channels)
        channels.each do |chan|
          Channel(chan).send msg
        end
      end
    end

    def start_bot(nick, server, port)
      connected = false
      @bot = Cinch::Bot.new do
        configure do |c|
          c.nick            = nick
          c.server          = server
          c.port            = port
          c.channels        = @channels
          c.plugins.plugins = [KloggerIRCBot]

          on :connect do |m|
            connected = true
          end
        end
      end

      Thread.abort_on_exception = true
      @bot_thread = Thread.new do
        @bot.start
      end
      sleep 1 until connected
    end

    def stop_bot
      @bot.stop
      Thread.kill(@bot_thread)
    end

  end
end
