#!/bin/sh

if MOTD_DEPLOYMENT=$(timeout 3 bootc status 2>/dev/null); then
    export MOTD_DEPLOYMENT
else
    export MOTD_DEPLOYMENT='Deployment status unavailable. Run bootc status to inspect the booted image.'
fi

if [ -z "${MOTD_TIP+x}" ]; then
    MOTD_TIP=$(shuf -n 1 /usr/share/lyftos/motd/tips.txt)
fi
export MOTD_TIP

MOTD_GREENBOOT='Boot health not reported'
if [ -r /etc/motd.d/boot-status ]; then
    if grep -q 'status is GREEN' /etc/motd.d/boot-status; then
        MOTD_GREENBOOT='Boot Status: Healthy 󰄳'
    else
        MOTD_GREENBOOT=$(cat /etc/motd.d/boot-status)
    fi
fi
export MOTD_GREENBOOT
