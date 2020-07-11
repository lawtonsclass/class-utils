#!/bin/bash

if [[ $UID != 0 ]]; then
    echo "Please run this script as root"
    exit 1
fi

PATH=/bin:/usr/bin

cd /starter-code
git checkout -- .
git clean -f
git pull
chown -R root:root /starter-code
chmod -R 755 /starter-code