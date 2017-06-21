#!/bin/bash

echo  [`date`] Bootstrapping Varnish...

function clean_up {
    # Perform program exit housekeeping
    echo [`date`] Stopping the service
    service varnish stop
    exit
}

echo [`date`] Starting the services...

trap clean_up SIGTERM

service varnish start

sleep 2

service varnishncsa start

varnish-agent

# Hook to dispatch logs in graylog (Provisional, awaiting smarter & cleaner config)
/usr/bin/varnishncsa -a -P /var/run/varnishncsa/varnishncsa.pid -F "{\"method\": \"%m\", \"X-Match\": \"%{X-Match}i\", \"X-Location-Id\": \"%{X-Location-Id}i\"}" | grep -P --line-buffered "(BAN|PURGE)" | nc -w 1 -u graylog-server 5555 &

echo [`date`] Bootstrap finished

tail -f /dev/null &
child=$!
wait "$child"