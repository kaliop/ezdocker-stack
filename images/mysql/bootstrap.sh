#!/bin/bash

echo [`date`] Bootstrapping MySQL...

function clean_up {
    # Perform program exit housekeeping
    echo [`date`] Stopping the service...
    service mysql stop
    exit
}

# Fix UID & GID for user 'mysql'
echo [`date`] Fixing filesystem permissions...

ORIGPASSWD=$(cat /etc/passwd | grep mysql)
ORIG_UID=$(echo $ORIGPASSWD | cut -f3 -d:)
ORIG_GID=$(echo $ORIGPASSWD | cut -f4 -d:)
ORIG_HOME=$(echo "$ORIGPASSWD" | cut -f6 -d:)
DEV_UID=${DEV_UID:=$ORIG_UID}
DEV_GID=${DEV_GID:=$ORIG_GID}

if [ "$DEV_UID" -ne "$ORIG_UID" ] || [ "$DEV_GID" -ne "$ORIG_GID" ]; then

    # note: we allow non-unique user and group ids...
    groupmod -o -g "$DEV_GID" mysql
    usermod -o -u "$DEV_UID" -g "$DEV_GID" mysql

fi

chown -R mysql:mysql /var/run/mysqld

echo [`date`] Handing over control to /entrypoint.sh...

trap clean_up SIGTERM

/entrypoint.sh $@

tail -f /dev/null &
child=$!
wait "$child"