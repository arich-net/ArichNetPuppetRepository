# !/bin/bash
# List CLAMAV Alerts 
# Listing a TMP file
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
rm -rf /tmp/clamscan.log
clamscan -r / --infected --no-summary --exclude-dir=^/sys\|^/proc\|^/dev --log /tmp/clamscan.log > /dev/null 2>&1

echo "`date '+[%Y-%m-%d %H:%M:%S]'` Starting CLAMSCAN ALL..."
# Read ALL lines and append the date
while read line; do
	if [[ ($line =~ ^---.*) || ("$line" == "") ]]; then
    	continue
	else
    	DATE=`date '+[%Y-%m-%d %H:%M:%S]'`
        echo "${DATE} ${line}"
	fi	
done < "/tmp/clamscan.log"
echo "`date '+[%Y-%m-%d %H:%M:%S]'` CLAMSCAN ALL Finished"

# Remove TMP file
rm -rf /tmp/clamscan.log