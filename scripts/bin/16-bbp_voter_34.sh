votequant=1000.0000
# mpush="amcli -u http://sh-amnod.vmi.amax.dev:18188 push action"
mpush="amcli -u https://expnode.amaxscan.io push action"
mpkey=AM898h1RX9ycXSiEwu4CF4Ame5HXxtsjqsYqAm6kTwvi7ZBaHuQs
vote_filename="13-bbp_voter_34.txt"
bbplist_filename="13-bbp_list_34.txt"
bbp1000_filename="11-ibbp-all-1000.txt"

function reg_producer(){
    cat $bbp1000_filename | while IFS= read -r line; do
        acct=$line
        $mpush amax regproducer '["'$acct'", "'$mpkey'","", 0, 0]' -p $acct
    done
}
#reg_producer

function add_vote(){
  voter_array=()
  while read line; do
    voter_array+=("$line")
  done < ./${vote_filename}

  for i in "${!voter_array[@]}"; do
      voter=${voter_array[$i]}
      $mpush amax addvote '["'$voter'", "'$votequant' VOTE"]' -p $voter
  done
}

add_vote

function vote(){
  bbp_array=()
  while read line; do
    bbp_array+=("$line")
  done < ./${bbplist_filename}

  voter_array=()
  while read line2; do
    voter_array+=("$line2")
  done < ./${vote_filename}

  for i in "${!bbp_array[@]}"; do
      echo "i:"$i
      voter=${voter_array[$i]}
      bbps=${bbp_array[$i]}
      $mpush amax vote '["'$voter'", ['$bbps']]' -p $voter
  done
}

#vote
