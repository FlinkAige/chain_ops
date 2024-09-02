#!/bin/bash

amnod_url=https://aplinkdev.amaxscan.io
mcli="amcli -u ${amnod_url}"

has_more=true
next_key=0
num=0
max_num=2000
file=all.prod.json
echo -n "[" > ${file}
while [[ ${has_more} == true ]];
do
  prods_info=$( $mcli get table amax amax producers -l ${max_num} --index 3 --key-type i128 -L "${next_key}" )
  rows=$( echo ${prods_info} | jq -c '.rows[]' )
  echo "got producer count: $( echo ${prods_info} | jq '.rows | length ' )"

  echo "$rows" | while IFS= read -r row; do
    if [[ $num -ne 0 ]]; then
      echo -n "," >> ${file}
    fi
    echo "$row" >> ${file}
    num=$(( num + 1 ))
    if [[ $num -ge $max_num ]]; then
      break
    fi
  done
  has_more=$(echo $prods_info | jq -r '.more' )
  next_key=$(echo $prods_info | jq -r '.next_key' )
done
echo -n "]" >> ${file}