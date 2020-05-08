#!/bin/bash

################################################################################
# global variables
################################################################################
ARCH_GNU=x86_64-linux-gnu # used for debian
ARCH_GNU=arm-linux-gnueabihf # used for raspberry

YUBIKEYNUM=1
PATH_TO_CERTIFICATE="/etc/ssh-ca/yubikey$YUBIKEYNUM.pub"
DESTINATION_PATH="/etc/ssh-ca"
PATH_TO_README="/etc/ssh-ca/README.md"

# user input
HOST=''
DURATION='1W'
PRINCIPALS=''
FILE=''

print_usage() {
    echo "generate_host_certificate [-I host_ID] [-f file] [-V duration_of_certificates_in_days] [-n principals]"
}

set -e # exit on any error

while getopts I:f:V:n:h option
do
case "${option}"
in
I) HOST=${OPTARG} ;;
f) FILE=${OPTARG} ;;
V) DURATION=${OPTARG} ;;
n) PRINCIPALS=${OPTARG} ;;
h) print_usage; 
   exit 1 ;;
*) print_usage; 
   exit 1 ;;
esac
done

################################################################################
# sign keys
################################################################################
cp $FILE $HOST.pub
ssh-keygen -D /usr/lib/$ARCH_GNU/opensc-pkcs11.so -s $PATH_TO_CERTIFICATE -I $HOST -h -n $PRINCIPALS -V +$DURATION $HOST.pub

rm $HOST.pub
mv $HOST-cert.pub $DESTINATION_PATH

echo -e "\nThe certificates can be found here: $DESTINATION_PATH/$HOST\n"