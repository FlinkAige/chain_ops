#!/bin/bash

. /opt/amax/conf/bbpclaim.conf
amcli wallet unlock -n $wallet --password $password 2>&1 | echo "unlocked"

mcli='amcli -u https://aplinkdev.amaxscan.io'
con=amaxapplybbp

dates=$(date)
function bbpclaimreward(){
    i=1
    while true; do
        sleep 1

        echo "claiming: [ $i ]"

        errMsg=$( $mcli push action $con claimbbps '[30]' -p $submiter 2>&1 )
        #echo $? $errMsg

        [[ $i -eq 400 ]] | [[ $errMsg =~ "bbp" ]] && echo "done claiming - $dates"  && exit 0

  i=$((i + 1))
    done

}

bbpclaimreward