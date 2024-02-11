#!/bin/bash -e

############################################################################
#
# Replaces expected Keys in place in a config file
#
############################################################################

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}") 

CONFIG=$1

if [ ! -f $CONFIG ]; then
    echo "Could not find $CONFIG"
    exit 1
fi

RESOLVERS_PATH=$($SCRIPT_DIR/get-config.sh "resolvers")
AUTH_CONF_PATH=$($SCRIPT_DIR/get-config.sh "auth")

sed -i -e s!UPSTREAM!"$UPSTREAM"!g $CONFIG
sed -i -e s!PULL_THROUGH!"$PULL_THROUGH"!g $CONFIG
sed -i -e s!PORT!"$PORT"!g $CONFIG
sed -i -e s!CACHE_MAX_SIZE!"$CACHE_MAX_SIZE"!g $CONFIG
sed -i -e s!CACHE_KEY!"$CACHE_KEY"!g $CONFIG
sed -i -e s!SCHEME!"$SCHEME"!g $CONFIG
sed -i -e s!SSL_INCLUDE!"$SSL_INCLUDE"!g $CONFIG
sed -i -e s!SSL_LISTEN!"$SSL_LISTEN"!g $CONFIG
sed -i -e s!AUTH_CONF_PATH!"$AUTH_CONF_PATH"!g $CONFIG
sed -i -e s!RESOLVERS_PATH!"$RESOLVERS_PATH"!g $CONFIG
sed -i -e s!LOG_LEVEL!"$LOG_LEVEL"!g $CONFIG
