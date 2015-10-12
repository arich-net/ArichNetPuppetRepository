#!/bin/bash
# List CLAMAV Alerts 
# Listing a TMP file
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
TRANSACTION_ID=`date '+%Y%m%d%H%M%S'`

echo "`date '+[%Y-%m-%d %H:%M:%S]'`: TID=${TRANSACTION_ID}; Status=Starting CLAMSCAN ALL"

rm -rf /tmp/clamscan.log
clamscan -r / --infected --exclude-dir=^/sys\|^/proc\|^/dev --log /tmp/clamscan.log > /dev/null 2>&1

# Read ALL lines and append the date
while read line; do
        if [[ ($line =~ ^---.*) || ("$line" == "") ]]; then
                continue
        elif [[ $line =~ ^/.* ]]; then
                FILE=`echo "$line" | awk -F: '{print $1}'`
                MESSAGE=`echo "$line" | awk -F: '{print $2}' | sed -e s/^\ //g`
                DATE=`date '+[%Y-%m-%d %H:%M:%S]'`
                echo "${DATE}: TID=${TRANSACTION_ID}; Status=Virus Found; Message=${MESSAGE}; File=${FILE}"
        elif [[ $line =~ ^Scanned\ files.* ]]; then
                NUMBER_FILES=`echo "$line" | awk -F: '{print $2}'`
        elif [[ $line =~ ^Infected\ files.* ]]; then
                INFECTED_FILES=`echo "$line" | awk -F: '{print $2}'`
        else
                continue
        fi
done < "/tmp/clamscan.log"
echo "`date '+[%Y-%m-%d %H:%M:%S]'`: TID=${TRANSACTION_ID}; Status=CLAMSCAN ALL Finished; Scanned_Files=${NUMBER_FILES}; Infected_Files=${INFECTED_FILES}"

# Remove TMP file
rm -rf /tmp/clamscan.log