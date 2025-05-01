#mpush="amcli -u https://aplink.armonia.fund push action"
mcli="amcli -u https://chain.amaxtest.com"


votequant=500.00000000
$mpush amax addvote '["taaaa.bbp", "'$votequant' VOTE"]' -p taaaa.bbp
$mpush amax addvote '["taaab.bbp", "'$votequant' VOTE"]' -p taaab.bbp
$mpush amax addvote '["taaac.bbp", "'$votequant' VOTE"]' -p taaac.bbp
$mpush amax addvote '["taaad.bbp", "'$votequant' VOTE"]' -p taaad.bbp

