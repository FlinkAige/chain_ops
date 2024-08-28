#bin/sh
mcli="amcli -u https://expnode.amaxscan.io "
has_more=true
next_key=0

function row_field() {
    echo $row | jq -c ".$@"
}

while [[ ${has_more} == true ]]
do
prods_info=$( $mcli get table amax amax producers -L "${next_key}" )
rows=$( echo ${prods_info} | jq -c '.rows[]' )

echo "$rows" | while IFS= read -r row; do
    $mcli push action amax addproducer "[$(row_field owner),
        $(row_field producer_authority), $(row_field url),
        $(row_field location), $(row_field ext.reward_shared_ratio) ]" -p amaxapplybps@active
done
has_more=$(echo $prods_info | jq -r '.more' )
next_key=$(echo $prods_info | jq -r '.next_key' )
done