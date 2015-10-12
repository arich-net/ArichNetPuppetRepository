#!/bin/bash
#Automatically set home directories quota of new existent users in the AD
#
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

USERS=`getent passwd | awk -F: '$3 > 10000 {print $1}'` && for user in $USERS; do edquota -p flacroix $user; done