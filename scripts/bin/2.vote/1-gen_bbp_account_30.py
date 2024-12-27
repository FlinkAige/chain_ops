#!/usr/bin/python
# -*- coding: UTF-8 -*-

list = ['a','b','c','d','e','f','g','h','i','j']
def save_string_to_file(string, filename):
    with open(filename, 'a') as file:
        file.write(string)
def add_ram_command(account):
    command = "$mcli system buyram bbp " + account + " -k 5"
    save_string_to_file(command + "\n", "./2.internal_add_ram.sh")
def add_vote_command(account):
    command = "$mpush amax addvote '[\"" + account + "\", \"1000.0000 VOTE\"]' -p" + account
    save_string_to_file(command + "\n", "./3.internal_add_vote.sh")

def gen_vote_command(account, voters):
    command = "$mpush amax vote '[\"" + account + "\", [" + voters + "]]' -p" + account
    save_string_to_file(command + "\n", "./4.internal_vote.sh")

def gen_ovotes_group():
    save_string_to_file("mcli=\"amcli -u https://expnode.amaxscan.io \"\n", "./2.internal_add_ram.sh")
    save_string_to_file("mpush=\"amcli -u https://expnode.amaxscan.io push action\"\n", "./3.internal_add_vote.sh")
    save_string_to_file("mpush=\"amcli -u https://expnode.amaxscan.io push action\"\n", "./4.internal_vote.sh")
    i=0
    voters=""
    accounts=[]
    for i1 in range(1,2):
        for i2 in range(0,5):
            for i3 in range(0,10):
                for i4 in range(0,10):
                        acc=list[i1]+list[i2]+list[i3]+list[i4] +".bbp"
                        voters+= "\"" + acc  + "\""
                        accounts.append(acc)
                        i+=1
                        if(i%30==0):
                            index = int(i/30)
                            add_ram_command(accounts[index-1])
                            add_vote_command(accounts[index-1])
                            gen_vote_command(accounts[index-1], voters)
                            voters=""
                        else:
                            voters+=","
    if(i%30!=0):
        index = int(i/30)
        add_ram_command(accounts[index])
        add_vote_command(accounts[index])
        gen_vote_command(accounts[index], voters)
                            
gen_ovotes_group()