#!/bin/bash
#usage: cat "input" | bash ./DeactivateActives.sh > exitfile
#usage: "standard input" | bash ./DeactivateActives.sh > exitfile
#It reads from standard input a list of policies.
#It deactivates the policy and list it in exitfile

while read i
do /usr/openv/netbackup/bin/admincmd/bpplinfo $i -modify -inactive
echo $i
done

exit 0
