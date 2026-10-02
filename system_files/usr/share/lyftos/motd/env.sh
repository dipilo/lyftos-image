#!/bin/sh

if MOTD_DEPLOYMENT=$(timeout 3 bootc status 2>/dev/null); then
    export MOTD_DEPLOYMENT
else
    export MOTD_DEPLOYMENT='Deployment status unavailable. Run bootc status to inspect the booted image.'
fi
