<p align="left">
    <a href="https://hub.docker.com/r/esailors/aws-ecr-http-proxy" alt="Pulls">
        <img src="https://img.shields.io/docker/pulls/esailors/aws-ecr-http-proxy" /></a>
    <a href="https://www.esailors.de" alt="Maintained">
        <img src="https://img.shields.io/maintenance/yes/2022.svg" /></a>

</p>

# aws-ecr-http-proxy

A nginx push/pull proxy that forwards requests to [AWS ECR pull through caches](https://docs.aws.amazon.com/AmazonECR/latest/userguide/pull-through-cache.html) that you are expected to have set up.

This is valuable when you are stuck using things like the docker daemon or some containerd runtime that can't easily auth itself
to the ECR registry that you are trying to pull through.  The security requirement of this server is that it has the valid credentials 
to the ECR that you are accessing and that you must control access to the server instance if you have concerns about people pulling
through the cache.

Per the AWS documentation, you can configure roles that allow new pull throughs.  In its current setup, you would have to run 2 nginx
servers with different IAM roles and then point particular daemons to each mirror if you wanted to have one "auto-pull through" and one "read-only" 
server.  This may or may not be of concern to you given your setup.

## Use Case: Containerd

### Configuration:
The proxy is packaged in a docker container and can be configured with following environment variables:

| Environment Variable                | Description                                    | Status                            | Default    |
| :---------------------------------: | :--------------------------------------------: | :-------------------------------: | :--------: |
| `AWS_REGION`                        | AWS Region for AWS ECR                         | Required                          |            |
| `AWS_ACCESS_KEY_ID`                 | AWS Account Access Key ID                      | Optional                          |            |
| `AWS_SECRET_ACCESS_KEY`             | AWS Account Secret Access Key                  | Optional                          |            |
| `AWS_SESSION_TOKEN`                 | AWS session token (for local testing mainly)   | Optional                          |            |
| `AWS_USE_EC2_ROLE_FOR_AUTH`         | Set this to true if we do want to use aws roles for authentication instead of providing the secret and access keys explicitly | Optional                          |            |
| `UPSTREAM`                          | URL for AWS ECR                                | Required                          |            |
| `PULL_THROUGHS`                     | CSV of <ecr name>:<port> see [create-mirror-server](files/scripts/create-mirror-server.sh) for values | Required | |
| `RESOLVER`                          | DNS server override machine resolver for proxy | Optional                          |            |
| `CACHE_MAX_SIZE`                    | Maximum size for cache volume                  | Optional                          |  `75g`     |
| `CACHE_KEY`                         | Cache key used for the content by nginx        | Optional                          |  `$uri`    |
| `ENABLE_SSL`                        | Used to enable SSL/TLS for proxy               | Optional                          | `false`    |
| `REGISTRY_HTTP_TLS_KEY`             | Path to TLS key in the container               | Required with TLS                 |            |
| `REGISTRY_HTTP_TLS_CERTIFICATE`     | Path to TLS cert in the container              | Required with TLS                 |            |

#### Pull through caches

Per the aws documentation on using pull through caches, there are several different types of [pull through caches that you can use](https://docs.aws.amazon.com/AmazonECR/latest/userguide/pull-through-cache-working.html).  For the sake of ease of use, we distill them into supported tokens, that you can see at the top of
the create-mirror-server.sh.

Since a mirror does not really know which registry is being mirrored, you are required to open as many mirrors on different ports as ecr registries that you
are trying to use.  Additionally, if you are using the ecr-public pull through cache, we do a little extra work since docker has additional naming in the urls.

Example:

`PULL_THROUGHS=ecr-public-docker:5000,kubernetes:5001`

This will start a server that mirrors to ecr-public docker images on port 5000 and one that mirrors to the kubernetes pull through on 5001. Please note that you
have to have setup the pull through caches already and provided the correct permissions for said pull through caches.

### Example:

```sh
docker run -d --name docker-registry-proxy --net=host \
  -v /registry/local-storage/cache:/cache \
  -p 5000:5000 \
  -v /registry/certificate.pem:/opt/ssl/certificate.pem \
  -v /registry/key.pem:/opt/ssl/key.pem \
  -e UPSTREAM=https://XXXXXXXXXX.dkr.ecr.eu-central-1.amazonaws.com \
  -e PULL_THROUGHS=ecr-public-docker:5000 \
  -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
  -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
  -e AWS_REGION=${AWS_DEFAULT_REGION} \
  -e CACHE_MAX_SIZE=100g \
  -e ENABLE_SSL=true \
  -e REGISTRY_HTTP_TLS_KEY=/opt/ssl/key.pem \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/opt/ssl/certificate.pem \
  esailors/aws-ecr-http-proxy:latest
```

If you ran this command on "registry-proxy.example.com" you can now get your images using `docker pull registry-proxy.example.com:5000/repo/image`.

### Deploying the proxy

#### Deploying with ansible (TODO - support or remove)

Modify the ansible role [variables](https://github.com/eSailors/aws-ecr-http-proxy/tree/master/roles/docker-registry-proxy/defaults) according to your need and run the playbook as follow:
```sh
ansible-playbook -i hosts playbook-docker-registry-proxy.yaml
```
In case you want to enable SSL/TLS please replace the SSL certificates with the valid ones in [roles/docker-registry-proxy/files/*.pem](https://github.com/eSailors/aws-ecr-http-proxy/tree/master/roles/docker-registry-proxy/files)

#### Deploying on Kubernetes with Helm (TODO - support or remove)
You can install on Kubernetes using the [community-maintained chart](https://github.com/evryfs/helm-charts/tree/master/charts/ecr-proxy) like this:

```shell
helm repo add evryfs-oss https://evryfs.github.io/helm-charts/
helm install evryfs-oss/ecr-proxy --name ecr-proxy --namespace ecr-proxy
```

See the [values-file](https://github.com/evryfs/helm-charts/blob/master/charts/ecr-proxy/values.yaml) for configuration parameters.


### Note on SSL/TLS
The proxy is using `HTTP` (plain text) as default protocol for now. So in order to avoid docker client complaining either:
 - (**Recommended**) Enable SSL/TLS using `ENABLE_SSL` configuration. For that you will have to mount your **valid** certificate/key in the container and pass the paths using  `REGISTRY_HTTP_TLS_*` variables.
 - Mark the registry host as insecure in your client [deamon config](https://docs.docker.com/registry/insecure/).
  
# Local Development

There is a rudimentary local development script for testing any changes to the server.  It consists of:

1. a script to bring up the proxy locally (currently only patterned for http)
2. a script to bring up a local docker daemon container that is mapped to the proxy

In order to test, it is recommended that you, bring up both containers and then exec into the daemon container to run docker commands:

```shell
# After making sure AWS environment variables on on the shell

UPSTREAM="MyECR" ./local/local-deploy.sh
./


docker exec -it test-docker-daemon /bin/bash

# in the container shell - run your docker containers
docker run -it alpine

# Clean up all installs that you do for re-testing
docker rm -vf $(docker ps -aq)
docker rmi -f $(docker images -aq)
```

You can use the nginx logs and the daemon logs to verify that the proxy is working as anticipated.

## Gotchas

Please keep in mind that, if you're developing this for testing, you may be using an AWS role 

# Acknowledgements

This server also takes ideas from https://github.com/rpardini/docker-registry-proxy in order to enable http(s) proxy
behavior for coverage of all repos when using the Docker Daemon.  As noted above, containerD configurations may
decide if they want to bypass this by directly running to ECR or if they want to simply set this up as a registry
mirror on paths.