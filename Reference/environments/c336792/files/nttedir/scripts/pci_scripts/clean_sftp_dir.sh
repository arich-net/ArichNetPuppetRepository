#!/bin/bash
# CLEAN HOME AND TMP DIRECTORIES
# This script will clean files older than 24 hours on SFTP and TMP Directories 
# Version: 1 
# Developed: Ariel Vasquez
# Date: 2013-05-31
#
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

for FILE in /sftp/*/ /tmp/
do
	find -P "$FILE" -regextype sed -type f -ctime +1  -not \( -regex '\/sftp\/dev\/.*' \) -print -exec rm -rf {} \; > /tmp/removed_files.txt 2>&1	
done

# Read ALL lines and append the date
while read line; do
        logger "Event=File Removed; ${line}"
done < "/tmp/removed_files.txt"