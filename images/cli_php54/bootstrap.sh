#!/bin/bash

# @todo use /bin/sh instead of /bin/bash

echo [`date`] Bootstrapping the CLI server...


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

echo [`date`] Installing crontabs...

for user in `ls /tmp/cron.d`; do
    crontab -u "$user" "/tmp/cron.d/$user"
done

cron


echo [`date`] Bootstrap finished

tail -f /dev/null &
child=$!
wait "$child"