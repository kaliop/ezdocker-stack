#!/bin/bash

echo [`date`] Bootstrapping Haproxy...

function clean_up {
    # Perform program exit housekeeping
    echo [`date`] Stopping the service...
    service rsyslog stop
    service haproxy stop
    exit
}

trap clean_up SIGTERM

service rsyslog start

service haproxy restart

echo [`date`] Bootstrap finished

tail -f /dev/null &
child=$!
wait "$child"
