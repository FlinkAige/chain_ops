#!/usr/bin/python
# -*- coding: UTF-8 -*-

list = ['a','b','c','d','e','f','g','h','i','j']
def save_string_to_file(string, filename):
    with open(filename, 'a') as file:
        file.write(string)

def add_vote_command(account):
    command = "$mpush amax addvote '[\"" + account + "\", \"1000.0000 VOTE\"]' -p" + account
    save_string_to_file(command + "\n", "./internal_add_vote.sh")

def gen_vote_command(account, voters):
    command = "$mpush amax vote '[\"" + account + "\", [" + voters + "]]' -p" + account
    save_string_to_file(command + "\n", "./internal_vote.sh")
   
def gen_ovotes_group():
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
                            add_vote_command(accounts[index-1])
                            gen_vote_command(accounts[index-1], voters)
                            voters=""
                        else:
                            voters+=","
    if(i%30!=0):
        index = int(i/30)
        add_vote_command(accounts[index])
        gen_vote_command(accounts[index], voters)
                            
gen_ovotes_group()