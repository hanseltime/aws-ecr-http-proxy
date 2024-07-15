



docker build -f ${SCRIPT_DIR}/Dockerfile.dind -t local/docker-dind $SCRIPT_DIR --progress=plain 

docker run --privileged -d --name containerd-test \
  -v ${SCRIPT_DIR}/docker-containerd:/etc/docker \
  local/docker-dind