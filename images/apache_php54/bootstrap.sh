#!/bin/bash

# @todo use /bin/sh instead of /bin/bash

echo [`date`] Bootstrapping the Web server...

function clean_up {
    # Perform program exit housekeeping
    echo [`date`] Stopping the service...
    service apache2 stop
    exit
}

# Fix UID & GID for user 'site'
echo [`date`] Fixing filesystem permissions...

ORIGPASSWD=$(cat /etc/passwd | grep site)
ORIG_UID=$(echo $ORIGPASSWD | cut -f3 -d:)
ORIG_GID=$(echo $ORIGPASSWD | cut -f4 -d:)
ORIG_HOME=$(echo "$ORIGPASSWD" | cut -f6 -d:)
DEV_UID=${DEV_UID:=$ORIG_UID}
DEV_GID=${DEV_GID:=$ORIG_GID}

if [ "$DEV_UID" -ne "$ORIG_UID" ] || [ "$DEV_GID" -ne "$ORIG_GID" ]; then

    # note: we allow non-unique user and group ids...
    groupmod -o -g "$DEV_GID" site
    usermod -o -u "$DEV_UID" -g "$DEV_GID" site

    chown "${DEV_UID}":"${DEV_GID}" "${ORIG_HOME}"
    chown -R "${DEV_UID}":"${DEV_GID}" "${ORIG_HOME}"/.*

fi

chown -R site:site /var/lock/apache2

echo [`date`] Starting the service

#Load ez5 dynamic vhost (including common config) if files are found
if [ -f "/etc/apache2/sites-available/001-dynamic-vhost-ez5.conf" ] && [ -f "/etc/apache2/sites-available/ez5-common.conf" ];then
    a2ensite 001-dynamic-vhost-ez5.conf
fi

#Load ezplatform dynamic vhost (including common config) if files are found
if [ -f "/etc/apache2/sites-available/002-dynamic-vhost-ezplatform.conf" ] && [ -f "/etc/apache2/sites-available/ezplatform-common.conf" ];then
    a2ensite 002-dynamic-vhost-ezplatform.conf
fi

#Load ez4 dynamic vhost if found
if [ -f "/etc/apache2/sites-available/003-dynamic-vhost-ez4.conf" ];then
    a2ensite 003-dynamic-vhost-ez4.conf
fi

trap clean_up SIGTERM

service apache2 restart


echo [`date`] Bootstrap finished

tail -f /dev/null &
child=$!
wait "$child"