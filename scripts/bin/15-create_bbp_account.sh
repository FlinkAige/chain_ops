#!/bin/bash
mcli="amcli -u http://sh-amnod.vmi.amax.dev:18188" 
# mcli='amcli -u https://vmaxmall.amaxscan.io'
creator=bbp
owner=amax.dao@active
activer=amaxapplybbp@active
amaxpool=amaxapplybbp
amaxquant='1000.00000000'
votequant='1000.0000'
i=0
filename="11-ibbp-all-1000.txt"
function create_account(){
    cat $filename | while IFS= read -r line; do
        # 在这里对每一行的内容做操作
        echo "-----------create account: $line ------------"
        acct=$line
        $mcli system newaccount --stake-net "0.005000 AMAX" --stake-cpu "0.005000 AMAX" --buy-ram-kbytes 4 $creator $acct $owner $activer -p bbp
    done
}
create_account

function transfer_amax(){
    i=$((i+1))
    cat $filename | while IFS= read -r line; do
        if [ $i -lt 35 ];then
            acct=$line
            result=`$mcli get currency balance amax.token $acct`
            amax_quant=`echo $res | grep AMAX`
            if [ -z "$amax_quant" ];then
                echo "-----------transfer amax to account: $acct ------------"
                $mcli push action amax.token transfer '["'$amaxpool'", "'$acct'", "'$amaxquant' AMAX", ""]' -p $amaxpool
            fi
        else
            break
        fi
    done
}
# create_account
# transfer_amax






