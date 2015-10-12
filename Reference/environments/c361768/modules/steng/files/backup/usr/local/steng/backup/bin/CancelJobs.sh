#!/bin/bash

#Usage: cat "input" | bash ./CancelJobs.sh > "output file"
#usage: "standard input" | bash ./CancelJobs.sh > "output file"
#Reads from standard input a list of JobIds and cancel them.
#It returns cancelled JobId list.
#Result is stored in "output file"

while read i;
do
        echo Cancelling $i
        /usr/openv/netbackup/bin/admincmd/bpdbjobs -cancel $i
done

exit 0

