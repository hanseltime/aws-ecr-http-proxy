#!/bin/sh -e

#########################################################
#
# Starts a docker in docker daemon with the daemon.json
# pointing to the expected local nginx deploy.  This is
# for verifying `docker run` of images within the container
# to monitor that the changes are going through the proxy.
#
#########################################################

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}") 

docker build -f ${SCRIPT_DIR}/Dockerfile.dind -t local/docker-dind $SCRIPT_DIR --progress=plain 

docker run --privileged -d --name dind-test \
  -v ${SCRIPT_DIR}/docker:/etc/docker \
  local/docker-dind
