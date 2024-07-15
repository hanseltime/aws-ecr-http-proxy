#!/bin/bash -e

############################################################################
#
# Returns corresponding mapping info for each ecr token.  
# Specify for type for an output
#
# Created at a point in time from: https://docs.aws.amazon.com/AmazonECR/latest/userguide/pull-through-cache-working-pulling.html
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
        elif [ "$type" == "libtarget" ]; then
            echo "ecr-public/docker"
        else 
            echo "unexpected type $type"
            exit 1
        fi
        ;;
    "docker-hub")
        if [ "$type" == "domains" ]; then
            echo "TODO"
        elif [ "$type" == "target" ] || [ "$type" == "libtarget" ]; then
            echo "docker-hub"
        else 
            echo "unexpected type $type"
            exit 1
        fi
        ;;
    "kubernetes")
        if [ "$type" == "domains" ]; then
            echo "registry.k8s.io"
        elif [ "$type" == "target" ] || [ "$type" == "libtarget" ]; then
            echo "kubernetes"
        else 
            echo "unexpected type $type"
            exit 1
        fi
        ;;
    "quay")
        if [ "$type" == "domains" ]; then
            echo "quay.io"
        elif [ "$type" == "target" ] || [ "$type" == "libtarget" ]; then
            echo "quay"
        else 
            echo "unexpected type $type"
            exit 1
        fi
        ;;
    "github")
        if [ "$type" == "domains" ]; then
            echo "ghcr.io"
        elif [ "$type" == "target" ] || [ "$type" == "libtarget" ]; then
            echo "github"
        else 
            echo "unexpected type $type"
            exit 1
        fi
        ;;
    "azure")
        if [ "$type" == "domains" ]; then
            echo "azurecr.io"
        elif [ "$type" == "target" ] || [ "$type" == "libtarget" ]; then
            echo "azure"
        else 
            echo "unexpected type $type"
            exit 1
        fi
        ;;
    "gitlab")
        if [ "$type" == "domains" ]; then
            echo "gitlab.com"
        elif [ "$type" == "target" ] || [ "$type" == "libtarget" ]; then
            echo "gitlab"
        else 
            echo "unexpected type $type"
            exit 1
        fi
        ;;
    *)
        echo "Unaccounted for registry token for ${PULL_THROUGH_TOKEN}.  Please update pull-through-info.sh"
        exit 1
        ;;
esac