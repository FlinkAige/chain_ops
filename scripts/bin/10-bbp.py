#!/usr/bin/python
# -*- coding: UTF-8 -*-
 
list = ['a','b','c','d','e','f','g','h','i','j']
def save_string_to_file(string, filename):
    with open(filename, 'a') as file:
        file.write(string)
   
def gen_bbp_account(filename):
    for i1 in range(0,1):
        for i2 in range(0,10):
            for i3 in range(0,10):
                for i4 in range(0,10):
                        acc=list[i1]+list[i2]+list[i3]+list[i4] +".bbp"
                        save_string_to_file(acc + "\n", filename)


def gen_vote_command(account, voters, filename):
    command = voters
    save_string_to_file(command + "\n", filename)
def gen_votes_command(filenname):
    i=0
    voters=""
    accounts=[]
    for i1 in range(0,1):
        for i2 in range(0,10):
            for i3 in range(0,10):
                for i4 in range(0,10):
                        acc=list[i1]+list[i2]+list[i3]+list[i4] +".bbp"
                        voters+= "\"" + acc  + "\"" + ","
                        print(i)
                        accounts.append(acc)
                        i+=1
                        if(i%30==0):
                            voters=voters[:-1]
                            gen_vote_command(accounts[int(i/30 - 1)],voters, filenname)
                            voters=""
    voters=voters[:-1]
    gen_vote_command(accounts[int(i/30)],voters, filenname)

# gen_bbp_account("./10-ibbp.txt")
gen_votes_command("./13-bbp_list_34.txt")
