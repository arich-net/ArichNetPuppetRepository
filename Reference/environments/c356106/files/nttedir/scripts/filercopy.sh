#!/bin/bash
#! Checking both argumnets
#! sudoers entry
#! ALL ALL=(root) /usr/local/bin/filercopy.sh /filers/*/vol/vol0/* /home/*/*

if [[ "$1" == "" || "$2" == "" ]]; then
	echo "Usage: sudo /usr/local/bin/filescopy.sh source destination"
	echo "source: e.g. /filers/eux0600152.oob/vol/vol0/some_file.trc"
	echo "destination: e.g. /home/someuser/"
	exit 1
fi

# Getting the name of the file to copy
File=`basename $1`

if [ "$File" == "" ]; then
	echo "source: e.g. /filers/eux0600152.oob/vol/vol0/some_file.trc"
	exit 1
fi

# Getting the user
User=`who am i | awk '{print \$1}'`
Group=`groups ${User} | awk '{print \$3}'`

# Checking that the user is copying on their $HOME
if [[ $2 != /home/${User}* || $PWD != /home/${User}* ]]; then
		echo "The user should be under their own HOME directory"
		echo "The user should copy files under their own HOME directory"
		exit 1
fi

# Execute the copy
echo "Copying File ${File} to $2"
/bin/cp $1 $2

# Changing the permissions of the copied file
echo "Changing permissions User=>${User} Group=>${Group} to the file ${2}/${File}"
chown ${User}:${Group} ${2}/${File}

exit 0