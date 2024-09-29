con_bbp=bbptest12
tset $con_bbp amaxapplybbp
mpush $con_bbp setplanex '["'$plan_id'","'$bbp_quota'",1200, "'$begin'","'$end'","'$applyc'","'$fulfillc'", [[["8,AMAX", "amax.token"],"900.00000000 AMAX"], [["8,AMAE", "amae.token"], "0.00000000 AMAE"]], []]' -p $con_bbpplan_id=4
bbp_quota=250
applyc=17
fulfillc=17
begin=2024-09-28T00:00:00
end=2024-10-28T00:00:00mpush $con_bbp setplanex '["'$plan_id'","'$bbp_quota'",1200,  "'$begin'","'$end'","'$applyc'","'$fulfillc'", [[["8,AMAX", "amax.token"],"1200.00000000 AMAX"]], []]' -p $con_bbp

tcli set account permission $con_bbp active --add-code

con_bps=amaxapplybps
tnew $con_bps
tset $con_bps amaxapplybps
tcli set account permission $con_bps active --add-code

bbpadmin=bbpadmin
mpkey=AM7eC92DpDnMiiBC2jYS183cW1KKqry1CcqQYsqWesLxJ1XYQh7a
# tnew bbpadmin
tpush $con_bbp init '["'$bbpadmin'","'$mpkey'","'$con_bps'"]' -p $con_bbp
tpush $con_bps init '["'$bbpadmin'","'$con_bbp'",1300]' -p $con_bps
tcli get table $con_bbp $con_bbp "global"
tcli get table $con_bps $con_bps "global"


bbp_owner1=bbp.owner123
tnew $bbp_owner1

bbp_owner2=bbp.owner22
tnew $bbp_owner2

plan_id=1
bbp_quota=5
tpush $con_bbp setplan '["'$plan_id'","'$bbp_quota'",2, [[["8,AMAX", "amax.token"],"1.00000000 AMAX"], [["6,MUSDT", "amax.mtoken"], "0.000000 MUSDT"]], []]' -p $con_bbp
tcli get table $con_bbp $con_bbp "plans"

plan_id=2
bbp_quota=50
tpush $con_bbp setplan '["'$plan_id'","'$bbp_quota'",1200, [[["8,AMAX", "amax.token"],"600.00000000 AMAX"], [["8,AMAE", "amae.token"], "0.00000000 AMAE"]], []]' -p $con_bbp


plan_id=3
bbp_quota=100
tpush $con_bbp setplan '["'$plan_id'","'$bbp_quota'",1200, [[["8,AMAX", "amax.token"],"900.00000000 AMAX"], [["8,AMAE", "amae.token"], "0.00000000 AMAE"]], []]' -p $con_bbp


plan_id=4
bbp_quota=150
tpush $con_bbp setplan '["'$plan_id'","'$bbp_quota'",1200, [[["8,AMAX", "amax.token"],"1200.00000000 AMAX"]], []]' -p $con_bbp




tcli get table $con_bbp $con_bbp "plans"

plan_id=2
bbp_quota=50
tpush $con_bbp setplan '["'$plan_id'","'$bbp_quota'",2, [[["8,AMAX", "amax.token"],"1.00000000 AMAX"], [["6,MUSDT", "amax.mtoken"], "0.000000 MUSDT"]], []]' -p $con_bbp
tcli get table $con_bbp $con_bbp "plans"

tpush $con_bbp updatestatus '["apppp22","apppp22"]' -p $con_bbp

tnew bbpvote112
tnew bbpvote212
tnew bbpvote312

tnew bbpvote113
tnew bbpvote213
tnew bbpvote313
tnew bbpvote114
tnew bbpvote214
tnew bbpvote314

tpush $con_bbp addvoters '[["bbpvote112","bbpvote212","bbpvote312","bbpvote113","bbpvote213","bbpvote313"]]' -p $con_bbp
tcli get table $con_bbp $con_bbp "voters"
tcli get table $con_bbp $con_bbp "plans"


tcli get table $con_bbp $con_bbp "global"

tpush $con_bbp applybbp '["'$bbp_owner1'",1,"logo_uri","org_name", "org_info","mail","manifesto","url",1232, null]' -p $bbp_owner1
tcli get table $con_bbp $con_bbp "bbps"

tpush $con_bbp applybbp '["'$bbp_owner2'",2,"logo_uri","org_name", "org_info","mail","manifesto","url",1232, null]' -p $bbp_owner2

tcli push action amax.token  transfer '["amax", "'$bbp_owner1'", "10.00000000 AMAX", ""]' -p amax

bbp_owner1=bbp.owner123
tcli push action amax.mtoken  transfer '["ad", "'$bbp_owner1'", "10.000000 MUSDT", ""]' -p ad


tcli push action amax.token  transfer '["'$bbp_owner1'", "'$con_bbp'", "2.00001000 AMAX", ""]' -p $bbp_owner1
tcli push action amax.mtoken  transfer '["'$bbp_owner1'", "'$con_bbp'", "1.000010 MUSDT", ""]' -p $bbp_owner1

tcli get table $con_bbp $con_bbp "bbps"

tcli push action  $con_bbp tsetvoteridx '[18]' -p $con_bbp

tpush amax.ntoken transfer '{"from": "'$bbp_owner2'", "to": "'$con_bbp'", "assets": [[1, [1001, 0]]], "memo": ""}' --permission $bbp_owner2@active

tnew bbpvote112
tnew bbpvote212
tnew bbpvote312

con_bbp=bbptest12
voter=voteraaa
tpush amax updateauth '{"account":"'$voter'","permission":"active","parent":"owner","auth":{"threshold":1,"keys":[],"waits":[],"accounts":[{"weight":1,"permission":{"actor":"'$con_bbp'","permission":"active"}}]}}' -p $voter


bbpvote113
bbpvote213
bbpvote313

bbp_owner1=bbp.owner123
tpush $con_bbp refund '["'$bbp_owner1'"]' -p $con_bbp

tpush $con_bbp setbbp '[["b1.com"],"joss"]' -p $con_bbp

tpush $con_bbp claimbbps '[100]' -p $con_bbp


tpush $con_bbp initstats '[1,[[["8,AMAX","amax.token"],"2.00000000 AMAX"],[["8,AMAE","amae.token"],"2.00000000 AMAE"]] ]' -p $con_bbp


new_bbp=bbptest
older_bbp=b1.com
voterid=bbpvote113
tpush $con_bbp changebbp '["'$new_bbp'","'$older_bbp'","'$voterid'"]' -p $con_bbp