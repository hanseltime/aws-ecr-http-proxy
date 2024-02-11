#!/bin/bash -e

type=$1

dir="/usr/local/openresty/nginx/conf"

if [ $type == "dir" ]; then 
    echo "$dir" 
elif [ $type == "main" ]; then
    echo "$dir/nginx.conf"
elif [ $type == "mirror-template" ]; then
    echo "$dir/pull-through-server.conf"
elif [ $type == "auth" ]; then
    echo "$dir/ecr-auth.conf"
elif [ $type == "resolvers" ]; then
    echo "$dir/resolvers.conf"
else
    echo "unmapped type ${type}"
    exit 1
fi