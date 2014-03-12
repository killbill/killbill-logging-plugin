[![Build Status](https://travis-ci.org/killbill/killbill-logging-plugin.png)](https://travis-ci.org/killbill/killbill-logging-plugin)
[![Code Climate](https://codeclimate.com/github/killbill/killbill-logging-plugin.png)](https://codeclimate.com/github/killbill/killbill-logging-plugin)

killbill-logging-plugin
=======================

Plugin to log Kill Bill events to Syslog, IRC, emails, ...

Release builds are available on [Maven Central](http://search.maven.org/#search%7Cga%7C1%7Cg%3A%22org.kill-bill.billing.plugin.ruby%22%20AND%20a%3A%22logging-plugin%22) with coordinates `org.kill-bill.billing.plugin.ruby:logging-plugin`.

Configuration
-------------

The plugin expects a `klogger.yml` configuration file containing the following:

```
syslog:
  :enabled: true
  :ident: 'klogger'
  :options: 9 # ::Syslog::LOG_PID | ::Syslog::LOG_NDELAY
  :facility: 128 # ::Syslog::LOG_LOCAL0

irc:
  :enabled: true
  :channels: ['#killbilling']
  :nick: 'klogger'
  :server: 'irc.freenode.org'
  :port: 6667
  :password: 'foo'

email:
  :to: pierre@pierre.com
  :from: ops@pierre.com
  :enabled: true
  :address: 'smtp.gmail.com'
  :port: 587
  :domain: 'your.host.name'
  :username: 'username'
  :password: 'password'
  :authentication: 'plain'
  :enable_starttls_auto: true
```

By default, the plugin will look at the plugin directory root (where `killbill.properties` is located) to find this file.
Alternatively, set the Kill Bill system property `-Dorg.killbill.billing.osgi.bundles.jruby.conf.dir=/my/directory` to specify another location.
