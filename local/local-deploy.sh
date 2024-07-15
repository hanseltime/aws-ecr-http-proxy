#!/bin/bash -e

##################################################################################
#
# Assumes that you are on an allowed aws profile for ECR pull through on the shell
#
##################################################################################

if [ -z "$UPSTREAM" ]; then
  echo "Must supply Upstream repository"
  exit 1
fi

if [ -z "$PULL_THROUGH_MIRROR" ]; then
  echo "Must supply PULL_THROUGH_MIRROR csv"
  exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "Could not detect AWS_ACCESS_KEY_ID on shell.  Please ensure you are signed in on the shell."
  exit 1
fi

docker build -f Dockerfile -t local/docker-proxy . --progress=plain 
docker stop docker-registry-proxy || true && docker run -d --rm --name docker-registry-proxy \
  -p 5000:5000 \
  -p 443:443 \
  -p 80:80 \
  -p 3128:3128 \
  -e UPSTREAM="${UPSTREAM}" \
  -e PULL_THROUGH_MIRROR="${PULL_THROUGH_MIRROR}" \
  -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
  -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
  -e AWS_REGION="${AWS_REGION}" \
  -e AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}" \
  local/docker-proxy

# TODO - if you would like to run this locally with https, feel free to contribute back a reliable pattern
#   -e ENABLE_SSL=true \
#   -e REGISTRY_HTTP_TLS_KEY=/opt/ssl/key.pem \
# #   -e REGISTRY_HTTP_TLS_CERTIFICATE=/opt/ssl/certificate.pem \
#   -v /registry/local-storage/cache:/cache \
#   -v /registry/certificate.pem:/opt/ssl/certificate.pem \
#   -v /registry/key.pem:/opt/ssl/key.pem \