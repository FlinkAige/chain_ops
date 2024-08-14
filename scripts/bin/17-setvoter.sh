
voter_array=()
while read line; do
    voter_array+=("$line")
done < ./17-applybbp-voter.txt

mcli='amcli -u https://expnode.amaxscan.io'
# mcli="amcli -u http://sh-amnod.vmi.amax.dev:18188" 

for i in "${!voter_array[@]}"; do
    voter=${voter_array[$i]}
    $mcli push action amaxapplybbp addvoters '[ ['$voter']]' -p amaxapplybbp
done