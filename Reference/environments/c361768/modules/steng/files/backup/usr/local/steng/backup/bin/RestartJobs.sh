#!/bin/bash

#Usage: cat "input" | bash ./RestartJobs.sh > "output file"
#usage: "standard input" | bash ./RestartJobs.sh > "output file"
#Reads from standard input a list of previously stopped JobIds and restart them.
#It returns restarted JobId list.
#Result is stored in "output file"

while read i;
do
	echo Restarting $i
	/usr/openv/netbackup/bin/admincmd/bpdbjobs -restart $i
done

exit 0
