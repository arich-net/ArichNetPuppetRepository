#!/bin/bash
# CLAMAV SCANS ON HOME DIRECTORIES
# Version: 1 
# Developed: Ariel Vasquez
# Date: 2013-05-30
#
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
LOCKNAME=/tmp/clamscan_cron.lock
CLAMSCAN=clamscan
SCANDIRECTORIES="/home /tmp /sftp"
LOGFILE=/tmp/clamscan_cron.log
DATE=`date '+[%Y-%m-%d %H:%M:%S]'`

CLAMSCANOPTIONS="--recursive --no-summary --block-encrypted=yes --detect-structured=yes --structured-cc-count=3 \
     --exclude-dir=^/sftp/dev|^/sftp/lost+found \
     --exclude=\/\.viminfo\|\/\.bash_history\|\/\.bash_profile\|\/\.profile\|\/\.gnupg\|\/\.debtags\|\/\.bashrc\|\/\.gem\|\/\.lesshst\|\/\.ssh\|\/\.aptitude\|\/\.rnd\|\/\.cache\|\/\.screenrc\|\/\.bash_logout \
     --move=/quarantine $SCANDIRECTORIES"

eval lockfile-check --lock-name $LOCKNAME > /dev/null 2>&1                                                                                      
ret_code=$?   

if [ $ret_code == 0 ] 
then
		echo "${DATE} ERROR another scan is taking place..." 
else		
		echo "${DATE} Starting Scanning HOME, TMP, and SFTP for Virus and Credit Card Information..."
		eval lockfile-create --retry 0 --lock-name $LOCKNAME > /dev/null 2>&1
		rm -rf $LOGFILE
		nice -n 10 $CLAMSCAN $CLAMSCANOPTIONS > $ 2>&1
		
		# Read ALL lines and append the date
		while read line; do
			if [[ ($line =~ ^---.*) || ("$line" == "") ]]; then
            	continue
       		else
            	DATE=`date '+[%Y-%m-%d %H:%M:%S]'`
                echo "${DATE} ${line}"
			fi
		done < "$LOGFILE"
		
		eval lockfile-remove --lock-name $LOCKNAME
		ret_code=$?
		DATE=`date '+[%Y-%m-%d %H:%M:%S]'`
		echo "${DATE} Scan Finished on HOME, TMP and SFTP ."
		echo "${DATE} Changing ownership of /quarantine Files"
		chown -R root:AG_UNIX_SFTP_ADMINS /quarantine
		rm -rf $LOGFILE
fi

exit $ret_code