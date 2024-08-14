#!/bin/bash
# mcli="amcli -u http://sh-amnod.vmi.amax.dev:18188" 
mcli='amcli -u https://expnode.amaxscan.io'
creator=bbp
owner=amax.dao@active
activer=amaxapplybbp@active
i=0
filename="20-voter.txt"
function create_account(){
    cat $filename | while IFS= read -r line; do
        # 在这里对每一行的内容做操作
        echo "-----------create account: $line ------------"
        acct=$line
        $mcli system newaccount --stake-net "0.005000 AMAX" --stake-cpu "0.005000 AMAX" --buy-ram-kbytes 4 $creator $acct $owner $activer -p bbp
    done
}
create_account
