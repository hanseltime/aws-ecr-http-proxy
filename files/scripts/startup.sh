#!/bin/bash

set -e

set -x

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}") 

if [ -z "$UPSTREAM" ] ; then
  echo "UPSTREAM not set."
  exit 1
fi

if [ -z "$PULL_THROUGH_MIRROR" ]; then
  echo "PULL_THROUGH_MIRROR not set."
  exit 1
fi

if [ -z "$PORT" ] ; then
  echo "PORT not set."
  exit 1
fi

if [ -z "$AWS_REGION" ] ; then
  echo "AWS_REGION not set."
  exit 1
fi

if [ -z "$AWS_USE_EC2_ROLE_FOR_AUTH" ] || [ "$AWS_USE_EC2_ROLE_FOR_AUTH" != "true" ]; then
  if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY not set."
    exit 1
  fi
fi

# Setup resolvers
$SCRIPT_DIR/set-resolver-config.sh

# Setup Logging directory
if [ ! -d /var/log/nginx ]; then
  mkdir /var/log/nginx
fi

export SCHEME=http
CONFIG=$(${SCRIPT_DIR}/get-config.sh "main")
SSL_CONFIG=/usr/local/openresty/nginx/conf/ssl.conf

if [ "$ENABLE_SSL" ]; then
  sed -i -e s!REGISTRY_HTTP_TLS_CERTIFICATE!"$REGISTRY_HTTP_TLS_CERTIFICATE"!g $SSL_CONFIG
  sed -i -e s!REGISTRY_HTTP_TLS_KEY!"$REGISTRY_HTTP_TLS_KEY"!g $SSL_CONFIG
  export SSL_LISTEN="ssl"
  export SSL_INCLUDE="include $SSL_CONFIG;"
  export SCHEME="https"
fi

export LOG_LEVEL=debug

# Update the base config
${SCRIPT_DIR}/replace-keys-in.sh $CONFIG

# setup ~/.aws directory
AWS_FOLDER='/root/.aws'
mkdir -p ${AWS_FOLDER}
echo "[default]" > ${AWS_FOLDER}/config
echo "region = $AWS_REGION" >> ${AWS_FOLDER}/config

if [ -z "$AWS_USE_EC2_ROLE_FOR_AUTH" ] || [ "$AWS_USE_EC2_ROLE_FOR_AUTH" != "true" ]; then
  set +x
  echo "Setting AWS Credentials for reuse"
  echo "[default]" > ${AWS_FOLDER}/credentials
  echo "aws_access_key_id=$AWS_ACCESS_KEY_ID" >> ${AWS_FOLDER}/credentials
  echo "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" >> ${AWS_FOLDER}/credentials
  if [ ! -z "$AWS_SESSION_TOKEN" ]; then
    echo "aws_session_token=$AWS_SESSION_TOKEN" >> ${AWS_FOLDER}/credentials
  fi
  set -x
fi
chmod 600 -R ${AWS_FOLDER}

set +x
# Get The ECR token initially and store it in the referenced config
TOKEN=$(aws ecr get-authorization-token --output text --query 'authorizationData[].authorizationToken')
$SCRIPT_DIR/replace_token.sh "$TOKEN"
set -x

# Create an array by splitting the string
# Set IFS to comma
IFS=',' read -ra array <<< "$PULL_THROUGH_MIRROR"

# Create a new mirror server for each pull through element
for pull_through_compound in "${array[@]}"; do
    # Get PORT and Pull Through
    IFS=':' read -ra parts <<< "$pull_through_compound"
    pull_through="${parts[0]}"
    port="${parts[1]}"
    # Setup the mirrors
    $SCRIPT_DIR/create-mirror-server.sh $UPSTREAM $pull_through $port
done

# make sure cache directory has correct ownership
chown -R nginx:nginx /cache

echo "Testing nginx config..."
# nginx -t

exec "$@"
