#!/bin/bash

echo  [`date`] Bootstrapping Nginx...

function clean_up {
    # Perform program exit housekeeping
    echo [`date`] Stopping the service
    service nginx stop
    service php7.1-fpm stop
    exit
}

# Fix UID & GID for user 'site'

echo [`date`] Fixing filesystem permissions...

ORIGPASSWD=$(cat /etc/passwd | grep site)
ORIG_UID=$(echo "$ORIGPASSWD" | cut -f3 -d:)
ORIG_GID=$(echo "$ORIGPASSWD" | cut -f4 -d:)
ORIG_HOME=$(echo "$ORIGPASSWD" | cut -f6 -d:)
DEV_UID=${DEV_UID:=$ORIG_UID}
DEV_GID=${DEV_GID:=$ORIG_GID}

if [ "$DEV_UID" -ne "$ORIG_UID" ] || [ "$DEV_GID" -ne "$ORIG_GID" ]; then

    groupmod -g "$DEV_GID" site
    usermod -u "$DEV_UID" -g "$DEV_GID" site

    chown "${DEV_UID}":"${DEV_GID}" "${ORIG_HOME}"
    chown -R "${DEV_UID}":"${DEV_GID}" "${ORIG_HOME}"/.*

fi

echo [`date`] Starting the service...

trap clean_up SIGTERM

service nginx start
service php7.1-fpm start

echo [`date`] Bootstrap finised

tail -f /dev/null &
child=$!
wait "$child"
