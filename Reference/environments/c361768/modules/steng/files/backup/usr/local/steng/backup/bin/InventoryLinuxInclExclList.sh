#!/bin/bash
#
###############################################################################################
# Version: 1.0
# Created By: MS Storage Engineering - 2014/02/18
# Modified by:
# Changelog:
# V1.0 First review
# How to use: ./InventoryLinuxInclExclList.sh $PATH/LINUX_CLIENT_LIST $DESTINATION_PATH
# Example: ./InventoryLinuxInclExclList.sh lin_client_list.txt /usr/local/steng/backup/bin/logs
#
# Result: return a unique list with Include+Exclude backup list for each client include within
# list parameter.
#
###############################################################################################

# Media file list to expire:
MEDIAS_FILE=$1
# Log files:
DEST_PATH=$2
# Result file:
RES_FILE="$DEST_PATH/result_linux_$(date +%Y%m%d_%H%M).txt"

        # Create log directofy if does not exist
        if [[ ! -d "$DEST_PATH" ]]; then
                mkdir $DEST_PATH
        fi
        echo "Result file: $RES_FILE"

        media_list=`cat $MEDIAS_FILE`
        for client in $media_list
        do
                /usr/openv/netbackup/bin/admincmd/bpgetconfig -e $DEST_PATH/excl_$client $client
                /usr/openv/netbackup/bin/admincmd/bpgetconfig -i $DEST_PATH/incl_$client $client
                echo "########################################################" >> $RES_FILE
                echo "# Client Server: $client" >> $RES_FILE
                if [[ -e $DEST_PATH/excl_$client ]]; then
                        echo "### Exclude list:" >> $RES_FILE
                        cat $DEST_PATH/excl_$client >> $RES_FILE
                        rm -f $DEST_PATH/excl_$client
                fi
                if [[ -e $DEST_PATH/incl_$client ]]; then
                        echo "### Include list:" >> $RES_FILE
                        cat $DEST_PATH/incl_$client >> $RES_FILE
                        rm -f $DEST_PATH/incl_$client
                fi
                echo "########################################################" >> $RES_FILE
done

echo "Inventory finished..."

