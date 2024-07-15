#!/bin/bash -e

############################################################################
#
# Create and insert a server config for the particular upstream ECR and pull
# through cache type.
#
# INFLUENCE CREDIT: https://github.com/rpardini/docker-registry-proxy/blob/master/entrypoint.sh
#
############################################################################

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}") 

export UPSTREAM=$1
export PULL_THROUGH_TOKEN=$2
export PORT=$3

if [ -z "$UPSTREAM" ]; then
    echo "Must supply non-empty UPSTREAM argument"
    exit 1
fi

if [ -z "$PULL_THROUGH_TOKEN" ]; then
    echo "Must supply non-empty PULL_THROUGH_TOKEN argument"
    exit 1
fi

if [ -z "$PORT" ]; then
    echo "Must supply non-empty PORT argument"
    exit 1
fi

# export the target pull through for the template - will fail if unmapped
export PULL_THROUGH=$($SCRIPT_DIR/pull-through-info.sh $PULL_THROUGH_TOKEN "target")
export PULL_THROUGH_LIB=$($SCRIPT_DIR/pull-through-info.sh $PULL_THROUGH_TOKEN "libtarget")


echo "Creating Mirror Server for $PULL_THROUGH_TOKEN"

CONF_DIR=$($SCRIPT_DIR/get-config.sh "dir")
PULL_THROUGH_TEMPLATE=$($SCRIPT_DIR/get-config.sh "mirror-template")
CONF=$($SCRIPT_DIR/get-config.sh "main")

pull_through_config="$CONF_DIR/mirror-${PULL_THROUGH_TOKEN}.conf"

cp $PULL_THROUGH_TEMPLATE $pull_through_config

$SCRIPT_DIR/replace-keys-in.sh "$pull_through_config"

escaped_pull_through_config=$(echo "$pull_through_config" | sed 's/\//\\\//g')

# Now insert in the nginx config the included server config
sed -i -e "/^[[:space:]]*# start-nginx-mirrors/s/^\([[:space:]]*\)\(# .*\)/\1include $escaped_pull_through_config;\n\1\2/" $CONF


# Add to health-check script
echo "wget localhost:$PORT/healthz -q -O - > /dev/null 2>&1" /health-check.sh
