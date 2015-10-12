#!/bin/bash
#usage: "bash GetActivePolicies.sh > exitfile" 
#it returns the list of active policies in that master server
for i in $(ls /usr/openv/netbackup/db/class)
do
if [ -z `grep -l "ACTIVE 1" /usr/openv/netbackup/db/class/$i/info` ]; then
echo $i
fi
done
exit 0
