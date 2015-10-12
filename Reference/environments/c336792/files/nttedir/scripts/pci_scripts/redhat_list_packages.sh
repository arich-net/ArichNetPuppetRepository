# !/bin/bash
# List installed software
# Listing installed siftware on a TMP file
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin 

rpm -qa --queryformat "Package=%{NAME}; Distribution=%{DISTRIBUTION}; Version=%{VERSION}\n" > /tmp/list.txt

# Read ALL lines and append the date
while read line; do
        logger "Action=Software Inventory; ${line}"
done < "/tmp/list.txt"
# Remove TMP file
rm -rf /tmp/list.txt