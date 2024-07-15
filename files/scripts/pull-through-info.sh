#!/bin/bash -e

############################################################################
#
# Returns corresponding mapping info for each ecr token.  
# Specify for type for an output
#
#
############################################################################

PULL_THROUGH_TOKEN=$1
type=$2

case $PULL_THROUGH_TOKEN in
    "ecr-public")
        if [ "$type" == "domains" ]; then
            echo "gallery.ecr.aws"
        elif [ "$type" == "target" ]; then
            echo "ecr-public"
        else 
            echo "unexpected type $type"
            exit 1
        fi
        ;;
    "ecr-public-docker")
        if [ "$type" == "domains" ]; then
            echo "registry-1.docker.io"
        elif [ "$type" == "target" ]; then
            echo "ecr-public/docker"
        else 
            echo "unexpected type $type"
            exit 1
        fi
        ;;
    "kubernetes")
        if [ "$type" == "domains" ]; then
            echo "registry.k8s.io"
        elif [ "$type" == "target" ]; then
            echo "kubernetes"
        else 
            echo "unexpected type $type"
            exit 1
        fi
        ;;
    "quay")
        if [ "$type" == "domains" ]; then
            echo "quay.io"
        elif [ "$type" == "target" ]; then
            echo "quay"
        else 
            echo "unexpected type $type"
            exit 1
        fi
        ;;
    # "github")
    #     echo "ghcr.io"
    #     ;;
    *)
        echo "Unaccounted for registry token for ${PULL_THROUGH_TOKEN}.  Please update pull-through-info.sh"
        exit 1
        ;;
esac