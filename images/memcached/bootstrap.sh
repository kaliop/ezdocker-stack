#!/bin/bash

echo [`date`] Bootstrapping Memcached...

function clean_up {
    # Perform program exit housekeeping
    echo [`date`] Stopping the service...
    service memcached stop
    exit
}

echo [`date`] Starting the service

trap clean_up SIGTERM

service memcached start

echo [`date`] Bootstrap finished

tail -f /dev/null &
child=$!
wait "$child"