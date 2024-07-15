#!/bin/bash -e

##################################################################################
#
# Assumes that you are on an allowed aws profile for ECR pull through on the shell
#
##################################################################################

if [ -z "$UPSTREAM" ]; then
  echo "Must supply Upstream repository"
fi

docker build -f Dockerfile -t local/docker-proxy . --progress=plain 
docker run -d --name docker-registry-proxy \
  -p 5000:5000 \
  -e UPSTREAM="${UPSTREAM}" \
  -e PULL_THROUGH="${PULL_THROUGH}" \
  -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
  -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
  -e AWS_REGION="${AWS_REGION}" \
  -e AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}" \
  -e CACHE_MAX_SIZE=100g \
  -e PULL_THROUGH_MIRROR=ecr-public-docker:5000 \
  local/docker-proxy

# TODO - if you would like to run this locally with https, feel free to contribute back a reliable pattern
#   -e ENABLE_SSL=true \
#   -e REGISTRY_HTTP_TLS_KEY=/opt/ssl/key.pem \
# #   -e REGISTRY_HTTP_TLS_CERTIFICATE=/opt/ssl/certificate.pem \
#   -v /registry/local-storage/cache:/cache \
#   -v /registry/certificate.pem:/opt/ssl/certificate.pem \
#   -v /registry/key.pem:/opt/ssl/key.pem \