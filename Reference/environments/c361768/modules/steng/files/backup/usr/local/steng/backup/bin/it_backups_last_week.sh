#!/bin/bash

FRED=`/usr/openv/netbackup/bin/admincmd/bpimagelist -l -hoursago 168 | grep IMAGE | grep -f /usr/local/steng/backup/bin/it_servers.txt | grep -v VMonthly | awk '{tot+=$19} END {print "Backed up " tot/1024/1024 " GBytes for IT in the last 7 days\n(excluding offsite backups)"}' ; echo -e "\nServer List:" ; cat /usr/local/steng/backup/bin/it_servers.txt`

echo -e "$FRED" | /bin/mail -s "IT backup status" bruce.givens@ntt.eu,alexander.schwarz@ntt.eu

