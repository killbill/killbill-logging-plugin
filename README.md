killbill-logging-plugin
=======================

Plugin to log Kill Bill events to Syslog, IRC, emails, ...

Release builds are available on [Maven Central](http://search.maven.org/#search%7Cga%7C1%7Cg%3A%22org.kill-bill.billing.plugin.ruby%22%20AND%20a%3A%22logging-plugin%22) with coordinates `org.kill-bill.billing.plugin.ruby:logging-plugin`.

Configuration
-------------

```
curl -v \
     -X POST \
     -u admin:password \
     -H 'X-Killbill-ApiKey: bob' \
     -H 'X-Killbill-ApiSecret: lazar' \
     -H 'X-Killbill-CreatedBy: admin' \
     -H 'Content-Type: text/plain' \
     -d '
syslog:
  :enabled: true
  :ident: 'klogger'
  :options: 9 # ::Syslog::LOG_PID | ::Syslog::LOG_NDELAY
  :facility: 128 # ::Syslog::LOG_LOCAL0

irc:
  :enabled: true
  :channels: ['#killbillio']
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
' \
     http://127.0.0.1:8080/1.0/kb/tenants/uploadPluginConfig/killbill-logger
```
