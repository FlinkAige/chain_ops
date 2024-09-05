#!/bin/bash
# mcli="amcli -u http://sh-amnod.vmi.amax.dev:18188" 
# con_bbp=bbptest12
. ~/.bbpclaim.conf

mcli='amcli -u https://expnode.amaxscan.io'
con_bbp=amaxapplybbp
amcli wallet unlock -n $wallet_name --password $password

function bbpclaimreward(){
    while true; do
        sleep 1
        ret=`$mcli push action $con_bbp claimbbps '[50]' -p $submiter 2>&1`
        check_results=`echo $ret | grep '[[1]]'`
        if [[ $check_results =~ "[[1]]" ]] 
        then 
            echo "error:...."
            break
        else     
            echo "success:..."
        fi
        
    done

}
bbpclaimreward