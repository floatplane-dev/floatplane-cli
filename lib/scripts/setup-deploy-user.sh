#!/bin/bash

set -e

deploy=$1

if id -u $deploy >/dev/null 2>&1; then
    echo "----------"
    echo "✅ Deploy user \"$deploy\" already exists"
    echo "----------"
else
    echo "----------"
    echo "Creating deploy user named: $deploy"
    echo "----------"
    ssh -t $server "sudo adduser --system --group --home /home/$deploy --shell /bin/bash $deploy"
    echo "----------"
    echo "✅ Created deploy user"
    echo "----------"
fi