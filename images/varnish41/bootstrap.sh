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

#fix permissions for logs folder that might be mounted on host
chmod 777 -R /var/log/varnish/

service varnish start

sleep 2

service varnishncsa start

varnish-agent

echo [`date`] Bootstrap finished

tail -f /dev/null &
child=$!
wait "$child"