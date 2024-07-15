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
INTERCEPT_MAP_PATH=$($SCRIPT_DIR/get-config.sh "intercepts")
TARGET_MAP_PATH=$($SCRIPT_DIR/get-config.sh "targets")
VERIFY_SSL_PATH=$($SCRIPT_DIR/get-config.sh "verify-ssl")

sed -i -e s!UPSTREAM!"$UPSTREAM"!g $CONFIG
sed -i -e s!PULL_THROUGH!"$PULL_THROUGH"!g $CONFIG
sed -i -e s!PULL_THROUGH_LIB!"$PULL_THROUGH_LIB"!g $CONFIG
sed -i -e s!PORT!"$PORT"!g $CONFIG
sed -i -e s!SCHEME!"$SCHEME"!g $CONFIG
sed -i -e s!SSL_INCLUDE!"$SSL_INCLUDE"!g $CONFIG
sed -i -e s!SSL_LISTEN!"$SSL_LISTEN"!g $CONFIG
sed -i -e s!AUTH_CONF_PATH!"$AUTH_CONF_PATH"!g $CONFIG
sed -i -e s!RESOLVERS_PATH!"$RESOLVERS_PATH"!g $CONFIG
sed -i -e s!LOG_LEVEL!"$LOG_LEVEL"!g $CONFIG
sed -i -e s!INTERCEPT_MAP_PATH!"$INTERCEPT_MAP_PATH"!g $CONFIG
sed -i -e s!TARGET_MAP_PATH!"$TARGET_MAP_PATH"!g $CONFIG
sed -i -e s!VERIFY_SSL_PATH!"$VERIFY_SSL_PATH"!g $CONFIG
