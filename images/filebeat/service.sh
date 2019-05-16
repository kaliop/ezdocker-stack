#!/bin/sh

# Copy config to have file with root owner
cp /mnt/conf.d/* /usr/share/filebeat/conf.d/
cd /usr/share/filebeat/conf.d/

configFileAmount=$(ls -l *.conf.yml | egrep -c '^-')
currentFile=0

# Avoid troll config
if [ $configFileAmount -gt 25 ];then
    echo "Too much config files detected"
    exit 1
fi

# Create a worker for each defined service, each one need his own registery so we make a folder for each
for f in *.conf.yml;do
    (( currentFile++ ))
    if [ $currentFile -eq $configFileAmount ];then
        mkdir "workdir-$f" && mv $f "workdir-$f" && cd "workdir-$f"
        exec filebeat -c $f
        cd ..
    else
        mkdir "workdir-$f" && mv $f "workdir-$f" && cd "workdir-$f"
        filebeat -c $f &
        cd ..
    fi
done
