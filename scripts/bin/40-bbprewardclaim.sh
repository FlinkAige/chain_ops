#!/bin/bash

. /opt/amax/conf/bbpclaim.conf
amcli wallet unlock -n $wallet --password $password 2>&1 | echo "unlocked"

mcli='amcli -u https://expnode.amaxscan.io'
con_bbp=amaxapplybbp

set -e
function bbpclaimreward(){
    i=1
    while true; do
        sleep 1

        echo "claim: $i" && $mcli push action $con_bbp claimbbps '[50]' -p $submiter 2>&1 | \
             echo "done claiming" && exit 1

  i=$((i + 1))
    done

}