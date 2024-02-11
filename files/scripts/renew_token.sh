#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}") 

# retry till new get new token
while true; do
  TOKEN=$(aws ecr get-authorization-token --output text --query 'authorizationData[].authorizationToken')
  echo "TOKEN IS $TOKEN"
  [ ! -z "${TOKEN}" ] && break
  echo "Warn: Unable to get new token, wait and retry!"
  sleep 30
done

$SCRIPT_DIR/replace_token.sh "$TOKEN"

nginx -s reload
