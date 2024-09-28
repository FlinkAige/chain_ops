#!/bin/bash
# mcli="amcli -u http://sh-amnod.vmi.amax.dev:18188" 
# con_bbp=bbptest12

mcli='amcli -u https://expnode.amaxscan.io'
con_bbp=amaxapplybbp
filename="40-ibbp-split.txt"
function addbbpsward(){
    cat $filename | while IFS= read -r line; do
        # 在这里对每一行的内容做操作
        parms=$line
        rewarder=$(echo $parms | cut -d '-' -f1)
        bbps=$(echo $parms | cut -d '-' -f2)
        $mcli push action $con_bbp addbbpreward '[ ['$bbps'],"'$rewarder'"]' -p $con_bbp
    done
}
addbbpsward