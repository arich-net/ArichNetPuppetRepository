#!/bin/bash
#
##################################################################################################
# Version: 1.0
# Created By: MS Storage Engineering - 2014/03/07
# Modified by:
# Changelog:
# V1.0 First review
# Script to inventory the Windows clients include list
#
# How to use: ./InventoryWindowsInclExclList.sh $PATH/WINDOWS_CLIENT_LIST $DESTINATION_PATH  
#  
##################################################################################################

# Media file list to expire:
MEDIAS_FILE=$1

# Log files:
DEST_PATH=$2
# Result file:
RES_FILE="$DEST_PATH/result_windows_$(date +%Y%m%d_%H%M).txt"

# Log Files
if [[ ! -d "$RES_FILE" ]]; then
        mkdir $DEST_PATH
fi
        echo "Result file: $RES_FILE"

media_list=`cat $MEDIAS_FILE`
for client in $media_list
do
        echo "########################################################" >> $RES_FILE
	echo "# Exclude $client..." >> $RES_FILE
        /usr/openv/netbackup/bin/admincmd/bpgetconfig -M $client | grep "^Exclude = " 2>&1>> $RES_FILE
        echo "# Include $client..." >> $RES_FILE
        /usr/openv/netbackup/bin/admincmd/bpgetconfig -M $client | grep "^Include = " 2>&1>> $RES_FILE
        echo "########################################################" >> $RES_FILE
done

echo "Inventory finished..."

