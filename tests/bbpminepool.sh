con_pool=pooll2
tnew $con_pool
tset $con_pool bbpminerpool


tcli set account permission $con_pool active --add-code

tpush $con_pool init '["'$con_pool'","1200.00000000 AMAX", "amgenesisdao"]' -p $con_pool

rewarder=aaa
tpush $con_pool addrewarder '["'$rewarder'"]' -p $con_pool

voter=bbb

tpush amax.token  transfer '["'$voter'", "'$con_pool'", "1.00000000 AMAX", "redeem"]' -p $voter


tpush amax.token  transfer '["'$rewarder'", "'$con_pool'", "1.00000000 AMAX", ""]' -p $rewarder

voter=ad
tpush amax.token  transfer '["'$voter'", "'$con_pool'", "1201.00000000 AMAX", ""]' -p $voter