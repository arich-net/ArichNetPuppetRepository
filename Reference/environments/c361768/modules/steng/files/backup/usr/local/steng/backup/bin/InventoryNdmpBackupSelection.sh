#!/bin/bash
#
###############################################################################################
# Version: 1.0
# Created By: MS Storage Engineering - 2014/03/07
# Modified by:
# Changelog:
# V1.0 First review
# How to use:   ./InventoryNdmpBackupSelection.sh $PATH/NDMP_CLIENT_LIST $DESTINATION_PATH
# Sample:       ./InventoryNdmpBackupSelection.sh ndmp_client_list.txt /usr/local/steng/backup/bin/logs
#
# Result: return a unique list with the Backup Selection for each client include within list
# parameter.
#
###############################################################################################

# Media file list to expire:
NDMP_CLIENT_LIST=$1
# Log files:
DEST_PATH=$2
# Result file:
RES_FILE="$DEST_PATH/result_ndmp_$(date +%Y%m%d_%H%M).txt"

# Create log directofy if does not exist.
        if [[ ! -d "$DEST_PATH" ]]; then
              mkdir $DEST_PATH
        fi
        echo "Result file: $RES_FILE"

        media_list=`cat $NDMP_CLIENT_LIST`
        for client in $media_list
        do
                /usr/openv/netbackup/bin/admincmd/bppllist -byclient $client | grep INCLUDE
                echo "########################################################" >> $RES_FILE
                echo "# NDMP Server: $client" >> $RES_FILE
                /usr/openv/netbackup/bin/admincmd/bppllist -byclient $client | grep INCLUDE >> $RES_FILE
                echo "########################################################" >> $RES_FILE
        done

echo "Inventory finished..."

