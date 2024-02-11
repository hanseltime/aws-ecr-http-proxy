#!/bin/bash -e

############################################################################
#
# Create a resolve config to match the host machine to avoid issues in deployment
# Also still supports resolver overrides via the environment variable RESOLVER
#
# INFLUENCE CREDIT: https://github.com/rpardini/docker-registry-proxy/blob/master/entrypoint.sh
#
############################################################################

confpath=$(${SCRIPT_DIR}/get-config.sh "resolvers")

if [ ! -z "$RESOLVER" ]; then
    echo "Using environment based RESOLVER ($RESOLVER) and skipping aligning to machine config!"
    echo "resolver $RESOLVER;" > $confpath
    exit
fi

echo "-- resolv.conf:"
cat /etc/resolv.conf
echo "-- end resolv"

# Podman adds a "%3" to the end of the last resolver? I don't get it. Strip it out.
export RESOLVERS=$(cat /etc/resolv.conf | sed -e 's/%3//g' | awk '$1 == "nameserver" {print ($2 ~ ":")? "["$2"]": $2}' ORS=' ' | sed 's/ *$//g')
if [ "x$RESOLVERS" = "x" ]; then
    echo "Warning: unable to determine DNS resolvers for nginx" >&2
    exit 66
fi

echo "DEBUG, determined RESOLVERS from /etc/resolv.conf: '$RESOLVERS'"

conf=""
for ONE_RESOLVER in ${RESOLVERS}; do
	echo "Possible resolver: $ONE_RESOLVER"
	conf="resolver $ONE_RESOLVER; "
done

echo "Final chosen resolver: $conf"
if [ ! -e $confpath ]
then
    echo "Using auto-determined resolver '$conf' via '$confpath'"
    echo "$conf" > $confpath
else
    echo "Not using resolver config, keep existing '$confpath' -- mounted by user?"
fi