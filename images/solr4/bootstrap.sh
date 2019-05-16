#!/bin/bash

echo [`date`] Bootstrapping Solr...

function clean_up {
    # Perform program exit housekeeping
    echo [`date`] Stopping the service...
    service solr stop
    exit
}

echo [`date`] Starting the service...

trap clean_up SIGTERM

service solr start

echo [`date`] Bootstrap finished

tail -f /dev/null &
child=$!
wait "$child"
