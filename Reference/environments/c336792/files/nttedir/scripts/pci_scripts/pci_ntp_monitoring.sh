# !/bin/bash
# NTP Peers monitoring
# 
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
TMPFILE=/tmp/ntpdc.txt
LOGFILE=/var/log/ntpmon.log

# Save NTP monitoring on a tmp file
ntpdc -n -c monlist \
	| egrep '(^83\.217\.239)|(^10\.201)|(^192\.168\.239)' \
	| awk '{print "RemoteIP=" $1 "; Average_Interval=" $8 "; Last_Update_Interval=" $9}' > $TMPFILE

# Read lines from this file and send them to the logger
while read line; do
        echo "`date '+[%Y-%m-%d %H:%M:%S]'` ntpmon: Action=NTP Monitoring; ${line}" >> $LOGFILE
done < "$TMPFILE"
# Remove TMP file
rm -rf $TMPFILE
