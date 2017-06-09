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

# Hook to dispatch logs in graylog (Provisional, awaiting smarter & cleaner config)
tail -f /opt/solr/logs/solr.log | nc -w 1 -u graylog-server 5556 &

echo [`date`] Bootstrap finished

tail -f /dev/null &
child=$!
wait "$child"