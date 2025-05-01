mpush="amcli -u https://aplink.armonia.fund push action"
# mcli="amcli -u https://chain.amaxtest.com"

votequant=5000000.0000
$mpush amax addvote '["apl51yxqgotk", "'$votequant' VOTE"]' -p apl51yxqgotk
$mpush amax addvote '["apl51bvjplwm", "'$votequant' VOTE"]' -p apl51bvjplwm
$mpush amax addvote '["apl51rnazcfy", "'$votequant' VOTE"]' -p apl51rnazcfy
$mpush amax addvote '["apl51khlbwue", "'$votequant' VOTE"]' -p apl51khlbwue



