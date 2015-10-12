#!/bin/bash
#!
#! Script to Sign IMM certificate requests
#! V1.1: Ariel Vasquez

if [[ "$1" == "" || $PWD != /home/${User}* ]]; then
	echo "You have to execute: ntt_sign_imm_cert.sh [CSR_File]"
	echo "The user should execute this script on their own HOME directory"	
	exit 1
fi
                                                                                                                                                                 # Converting the Request from DER format to PEM format                                                                                                             

echo "Converting $1 to PEM format"
openssl req -inform DER -in $1 -out ${1}.pem -outform PEM
if [[ $? -ne 0 ]]; then
	echo "The CSR is not in DER format - Nothing to sign"
    exit 1
fi

echo "Now we have to sign the request from ${1}.pem"
openssl ca -config /root/Certificate_Services/openssl.cnf -in ${1}.pem -out ${1}.crt
if [[ $? -ne 0 ]]; then
    exit 1
fi

echo "Now we generate the CRL File if is needed"
openssl ca -config /root/Certificate_Services/openssl.cnf -gencrl -out /root/Certificate_Services/PCI_CA/crl/crllist.pem
if [[ $? -ne 0 ]]; then
    exit 1
fi

cp /root/Certificate_Services/PCI_CA/crl/crllist.pem $PWD

echo "We have to convert the certificate to DER Format"
openssl x509 -in ${1}.crt -inform PEM -out ${1}-crt.der -outform DER

echo "Finally we have to change permission of generated files"

User=`who am i | awk '{print \$1}'`
Group=`groups ${User} | awk '{print \$3}'`

echo "Change the permissions to User: $User and Group $Group"

# Changing file permissions only on the ones created by the script
chown ${User}:${Group} ${1}.pem
chown ${User}:${Group} ${1}.crt
chown ${User}:${Group} crllist.pem
chown ${User}:${Group} ${1}-crt.der

# Exiting the script successfully
exit 0