#!/usr/bin/python
# -*- coding: UTF-8 -*-

list = ['a','b','c','d','e','f','g','h','i','j']
def save_string_to_file(string, filename):
    with open(filename, 'a') as file:
        file.write(string)

def gen_vote_command(account, voters):
    command = "$mpush amax vote '[\"" + account + "\", [" + voters + "]]' -p" + account
    save_string_to_file(command + "\n", "./12-bbp_vote_34.sh")
def gen_ovotes_group():
    i=0
    voters=""
    accounts=[]
    for i1 in range(0,2):
        for i2 in range(0,10):
            for i3 in range(0,10):
                for i4 in range(0,10):
                        acc=list[i1]+list[i2]+list[i3]+list[i4] +"v.bbp"
                        voters+= "\"" + acc  + "\"" + ","
                        accounts.append(acc)
                        i+=1
                        if(i%50==0):
                            save_string_to_file(voters + "\n", "./18-obbp-voter-list.txt")
                            voters=""
                            
gen_ovotes_group()

def gen_ovotes_list():
    i=0
    voters=""
    accounts=[]
    for i1 in range(0,2):
        for i2 in range(0,10):
            for i3 in range(0,10):
                for i4 in range(0,10):
                    acc=list[i1]+list[i2]+list[i3]+list[i4] +"v.bbp"
                    save_string_to_file(acc + "\n", "./18-obbp-voter.txt")      
#gen_ovotes_list()

