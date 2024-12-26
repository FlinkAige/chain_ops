#!/bin/bash
# mcli="amcli -u http://sh-amnod.vmi.amax.dev:18188" 
mcli='amcli -u https://expnode.amaxscan.io'
from=ad
filename="22-rewarder.txt"
function trasnfer_account(){
    cat $filename | while IFS= read -r line; do
        # 在这里对每一行的内容做操作
        echo "-----------create account: $line ------------"
        mcli transfer $from  $line" AMAX"
    done
}
trasnfer_account