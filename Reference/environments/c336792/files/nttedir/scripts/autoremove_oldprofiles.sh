#!/bin/bash
#Automatically remove ald home directories of non-existent users in the AD
#
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

for FILE in `find /home -maxdepth 1 -mtime +180 -type d -exec ls -dl {} \; | awk '($3 ~ /10[0-9][0-9][0-9]/) {print \$8}'`
do
SIZE=`du -h --max-depth=0 ${FILE} | awk '{print \$1}'`
echo "File to be removed: ${FILE}\tSize: ${SIZE}"
# Removing the File
rm -rf ${FILE}
echo "${FILE} removed"
done