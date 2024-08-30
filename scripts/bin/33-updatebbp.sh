
bbp_array=()
while read line; do
    bbp_array+=("$line")
done < ./33-bbpupdate_list.txt

mcli='amcli -u https://expnode.amaxscan.io'
# mcli="amcli -u http://sh-amnod.vmi.amax.dev:18188" 
mpkey=AM898h1RX9ycXSiEwu4CF4Ame5HXxtsjqsYqAm6kTwvi7ZBaHuQs
for i in "${!bbp_array[@]}"; do
    bbp=${bbp_array[$i]}
    $mcli push action amax addproducer '["'$bbp'", ["block_signing_authority_v0",[1,[["'$mpkey'",1]]]], "",0,0]' -p amaxapplybps@active
done