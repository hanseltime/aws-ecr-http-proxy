#!/bin/bash -e

# Replaces a TOKEN $1 in the nginx.conf

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}") 

TOKEN=$1

CONFIG=$($SCRIPT_DIR/get-config.sh "auth")

if [ -z "$TOKEN" ]; then
    echo "Must supply a non-empty token!"
    exit 1
fi

AUTH=$(grep X-Forwarded-User ${CONFIG} | grep -o -m1 'Basic [^ "]*')
AUTH_N="Basic ${TOKEN}"
sed -i "s|${AUTH}|${AUTH_N}|g" $CONFIG