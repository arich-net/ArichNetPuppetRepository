#!/bin/bash
#usage: cat "input" | bash ./DeactivateRollback.sh > exitfile
#usage: "standard input" | bash ./DeactivateRollback.sh > exitfile
#It reads from standard input a list of policies.
#It activates the policy and list it in exitfile

while read i
do /usr/openv/netbackup/bin/admincmd/bpplinfo $i -modify -active
echo $i
done

exit 0
