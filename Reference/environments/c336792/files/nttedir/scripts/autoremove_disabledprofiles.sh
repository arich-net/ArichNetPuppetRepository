#!/bin/bash
# Script to autoremove disabled accounts
#
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Print Date
echo "---------------------------------"
echo "`date`"
echo "---------------------------------"
# Get LDAP credentials
LDAPUSER="`cat /etc/ldap.conf | awk '(\$1 ~ /binddn/){ print \$2 " " \$3 " " \$4}'`"
LDAPPASSWD=`cat /etc/ldap.conf | awk '(\$1 ~ /bindpw/){ print \$2 }'`
LDAPSERVER=`cat /etc/ldap.conf | awk '($1 ~ /^uri/){print \$2}' | awk -F / '{print \$3}' | awk -F . '{print \$1}'`
DATE=`date --date='30 days ago' +%Y%m%d%H%M%S.0Z`

# echo "${DATE}"

SEARCH=`ldapsearch -Z -x -D "${LDAPUSER}" -w ${LDAPPASSWD} -h ${LDAPSERVER} -p 389 -b "OU=NTT EO Disabled Accounts,DC=ntteng,DC=ntt,DC=eu" "(&(objectClass=person)(userAccountControl=514)(whenChanged<=${DATE}))" sAMAccountName | awk '(\$1 ~ /sAMAccountName/) {print \$2}'`

for USER in $SEARCH
do
        if [ -d "/home/${USER}" ]; then
                SIZE=`du -h --max-depth=0 /home/${USER} | awk '{print \$1}'`
                echo "Directory for ${USER} exists with size of ${SIZE}"
                rm -rf /home/${USER}
        fi
done

