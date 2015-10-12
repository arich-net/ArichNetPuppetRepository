#!/bin/bash
# CLAMAV SCANS ON HOME SFTP AND TMP DIRECTORIES
# Version: 1 
# Developed: Ariel Vasquez
# Date: 2014-02-04
#
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
NOW_EPOCH_DATE=`date +%s`

# Get the expiration date
EXPIRATION_DATE=`sudo chage -l root | awk '(\$2 ~ /expires/) && (\$1 ~ /Password/) {print \$4 " " \$5 " " \$6}'`
EXP_EPOCH_DATE=$(date --date="$EXPIRATION_DATE" +%s)

# Calculate the difference in days
DAYS_FOR_EXPIRATION=$(( ($EXP_EPOCH_DATE - $NOW_EPOCH_DATE) / 86400 ))
#echo "PASSWORD WILL EXPIRE IN $DAYS_FOR_EXPIRATION"
echo $DAYS_FOR_EXPIRATION