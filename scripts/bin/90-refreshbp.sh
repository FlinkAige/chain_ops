
shopt -s expand_aliases

source ~/.bashrc

mcli='amcli -u https://*.fund'
IFS=$'\n\t'
for i in $(seq 1 680); do
    amcli -u https://aplink.armonia.fund push action amaxapplybps refreshbbp '[5]' -p apl5ijxk35n1
    echo "Refreshing block producers... $i"
    sleep 1
done
