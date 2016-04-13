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

echo [`date`] Bootstrap finished

tail -f /dev/null &
child=$!
wait "$child"