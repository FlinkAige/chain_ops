votequant=1000.0000
# mpush="amcli -u http://sh-amnod.vmi.amax.dev:18188 push action"
mpush="amcli -u https://expnode.amaxscan.io push action"
mpkey=AM898h1RX9ycXSiEwu4CF4Ame5HXxtsjqsYqAm6kTwvi7ZBaHuQs
bbp_filename="bbps.txt"

function reg_producer(){
    cat $bbp_filename | while IFS= read -r line; do
        acct=$line
        $mpush amax regproducer '["'$acct'", "'$mpkey'","", 0, 0]' -p $acct
    done
}
reg_producer