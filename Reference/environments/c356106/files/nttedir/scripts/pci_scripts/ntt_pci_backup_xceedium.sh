#!/bin/bash                                                                                                                                            
#!
#! Script to backup video records from Xceedium
#! V1. Ariel Vasquez
#!
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Local variables
DIRECTORYBACKUPS=/xceedium
REMOTEDIRECTORYBACKUPS=/backups/Xceedium
KEYFILE=/root/.ssh/id_backup_rsa
HOSTTOBACKUP=eul3300422.oob
USERBACKUP=backup
RECORDNUMBER=10

# Take the date
DATE=`date +"%Y/%m/%d %H:%M:%S"`

echo "${DATE} backup_status=OK Beginning The Backup Process"

# Backing up graphical sessions

echo "${DATE} backup_status=OK Starting Back Up Graphical Sessions"
for VIDEO in `lsattr ${DIRECTORYBACKUPS}/*.gsr | egrep -v '^\-u' | head -n ${RECORDNUMBER} | awk '{print \$2}'`
do
        VIDEOFILE=`basename ${VIDEO} | awk -F . '{print \$1}'`
        NUMBERFILES=`ls -l ${DIRECTORYBACKUPS} | egrep ${VIDEOFILE} | wc -l`
        if [ $NUMBERFILES -gt 1 ]; then
                COMPRESSRECORDS=""
                for FILES in `ls -l ${DIRECTORYBACKUPS} | egrep ${VIDEOFILE} | egrep -o 'eux[0-9]{7}\-.*'`
                do
                        COMPRESSRECORDS="${COMPRESSRECORDS} ${DIRECTORYBACKUPS}/${FILES}"
                done

                # Compressing Files
                echo "${DATE} backup_status=OK Compressing Files ${COMPRESSRECORDS} on 7Zip File /tmp/${VIDEOFILE}.7z"
                7zr a /tmp/${VIDEOFILE}.7z ${COMPRESSRECORDS} > /dev/null 
                if [[ $? -ne 0 ]]; then
                        echo "$DATE backup_status=ERROR compressing File /tmp/${VIDEOFILE}.7z"
                        exit 1
                fi

                # Copying compressed File
                echo "${DATE} backup_status=OK Secure Copying /tmp/${VIDEOFILE}.7z"
                scp -i ${KEYFILE} /tmp/${VIDEOFILE}.7z ${USERBACKUP}@${HOSTTOBACKUP}:${REMOTEDIRECTORYBACKUPS} > /dev/null
                if [[ $? -ne 0 ]]; then
                        echo "$DATE backup_status=ERROR copying File /tmp/${VIDEOFILE}.7z, check communications"
                        exit 1
                fi

                # Removing compressed File
                echo "${DATE} backup_status=OK Removing /tmp/${VIDEOFILE}.7z"
                rm -rf /tmp/${VIDEOFILE}.7z

        fi
        echo "${DATE} backup_status=OK Changing Extended attributes of ${VIDEO}"
        chattr +u ${VIDEO}
done
echo "${DATE} backup_status=OK Finished Back Up Graphical Sessions"


# Backing up text sessions

echo "${DATE} backup_status=OK Starting Back Up Text Sessions"
for TEXTO in `lsattr ${DIRECTORYBACKUPS}/*.txt | egrep -v '^\-u' | head -n ${RECORDNUMBER} | awk '{print \$2}'`
do
        TEXTOFILE=`basename ${TEXTO} | awk -F . '{print \$1}'`
        NUMBERFILES=`ls -l ${DIRECTORYBACKUPS} | egrep ${TEXTOFILE} | wc -l`
        if [ $NUMBERFILES -gt 1 ]; then
                COMPRESSRECORDS=""
                for FILES in `ls -l ${DIRECTORYBACKUPS} | egrep ${TEXTOFILE} | egrep -o 'eux[0-9]{7}\-.*'`
                do
                        COMPRESSRECORDS="${COMPRESSRECORDS} ${DIRECTORYBACKUPS}/${FILES}"
                done

                # Compressing Files
                echo "${DATE} backup_status=OK Compressing Files ${COMPRESSRECORDS} on 7Zip File /tmp/${TEXTOFILE}.7z"
                7zr a /tmp/${TEXTOFILE}.7z ${COMPRESSRECORDS} > /dev/null
                if [[ $? -ne 0 ]]; then
                        echo "$DATE backup_status=ERROR compressing File /tmp/${TEXTOFILE}.7z"
                        exit 1
                fi

                # Copying compressed File
                echo "${DATE} backup_status=OK Secure Copying /tmp/${TEXTOFILE}.7z"
                scp -i ${KEYFILE} /tmp/${TEXTOFILE}.7z ${USERBACKUP}@${HOSTTOBACKUP}:${REMOTEDIRECTORYBACKUPS} > /dev/null
                if [[ $? -ne 0 ]]; then
                        echo "$DATE backup_status=ERROR copying File /tmp/${TEXTOFILE}.7z, check communications"
                        exit 1
                fi

                # Removing compressed File
                echo "${DATE} backup_status=OK Removing /tmp/${TEXTOFILE}.7z"
                rm -rf /tmp/${TEXTOFILE}.7z

        fi
        echo "${DATE} backup_status=OK Changing Extended attributes of ${TEXTO}"
        chattr +u ${TEXTO}
done
echo "${DATE} backup_status=OK Finished Back Up Text Sessions"
exit 0
        