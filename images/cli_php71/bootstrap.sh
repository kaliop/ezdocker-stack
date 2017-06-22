#!/bin/bash

# @todo use /bin/sh instead of /bin/bash

echo [`date`] Bootstrapping the CLI container ...

function clean_up {
    # Perform program exit housekeeping
    echo [`date`] Stopping the container...
    exit
}

trap clean_up SIGTERM

# Composer config
if [ "$GITHUB_OAUTH" ]; then
	echo Bootstraping composer github config
	echo '{ "config": { "github-oauth": { "github.com": "'$GITHUB_OAUTH'" } } }' > /home/site/.composer/config.json
fi

if [ "$COMPOSER_HTTP_AUTH_DOMAIN" ] && [ "$COMPOSER_HTTP_AUTH_LOGIN" ] && [ "$COMPOSER_HTTP_AUTH_PASSWORD" ]; then
	echo Bootstraping composer http-basic auth config
	echo '{ "http-basic": { "'$COMPOSER_HTTP_AUTH_DOMAIN'": { "username": "'$COMPOSER_HTTP_AUTH_LOGIN'", "password": "'$COMPOSER_HTTP_AUTH_PASSWORD'" } } }' > /home/site/.composer/auth.json
fi

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