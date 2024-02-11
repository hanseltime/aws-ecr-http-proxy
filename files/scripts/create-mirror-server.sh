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
export PULL_THROUGH=$2
export PORT=$3

if [ -z "$UPSTREAM" ]; then
    echo "Must supply non-empty UPSTREAM argument"
    exit 1
fi

if [ -z "$PULL_THROUGH" ]; then
    echo "Must supply non-empty PULL_THROUGH argument"
    exit 1
fi

if [ -z "$PORT" ]; then
    echo "Must supply non-empty PORT argument"
    exit 1
fi

ecr_pull_throughs=("ecr-public" "ecr-public-docker" "kubernetes" "quay" "docker-hub" "github" "azure")

found=false
for element in "${ecr_pull_throughs[@]}"; do
    if [ "$element" == "$PULL_THROUGH" ]; then
        found=true
        break
    fi
done

if [ "$found" == "false" ]; then
  echo "Unsupported ECR Pull through cache ${PULL_THROUGH}"
  exit 1
fi

echo "Creating Mirror Server for $PULL_THROUGH"

CONF_DIR=$($SCRIPT_DIR/get-config.sh "dir")
PULL_THROUGH_TEMPLATE=$($SCRIPT_DIR/get-config.sh "mirror-template")
CONF=$($SCRIPT_DIR/get-config.sh "main")

pull_through_config="$CONF_DIR/mirror-${PULL_THROUGH}.conf"

cp $PULL_THROUGH_TEMPLATE $pull_through_config

# For ecr-public docker we use a different look up "ecr-public/docker"
if [ "$PULL_THROUGH" == "ecr-public-docker" ]; then
    export PULL_THROUGH="ecr-public/docker"
fi

$SCRIPT_DIR/replace-keys-in.sh "$pull_through_config"

escaped_pull_through_config=$(echo "$pull_through_config" | sed 's/\//\\\//g')

# Now insert in the nginx config the included server config
sed -i -e "/^[[:space:]]*# start-nginx-mirrors/s/^\([[:space:]]*\)\(# .*\)/\1include $escaped_pull_through_config;\n\1\2/" $CONF


# Add to health-check script
echo "wget localhost:$PORT/healthz -q -O - > /dev/null 2>&1" /health-check.sh
