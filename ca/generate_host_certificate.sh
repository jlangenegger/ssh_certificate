#!/bin/bash

################################################################################
# global variables
################################################################################
YUBIKEYNUM=0

SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`

PATH_TO_YKCS11="/usr/local/lib/libykcs11.so"
PATH_TO_CERTIFICATE="/etc/ssh-ca/yubikey$YUBIKEYNUM.pub"
DESTINATION_PATH="$HOME/signed_keys"
PATH_TO_README="$SCRIPTPATH/../host/README.md"

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

# check user input
if [ "$HOST" == "" ]; then
   print_usage
   exit 1;
fi
if [ "$FILE" == "" ]; then
   print_usage
   exit 1;
fi

################################################################################
# sign keys
################################################################################
mkdir -p $DESTINATION_PATH

cp $FILE $HOST.pub
ssh-keygen -D $PATH_TO_YKCS11 -s $PATH_TO_CERTIFICATE -I $HOST -h -n $PRINCIPALS -V +$DURATION $HOST.pub

rm $HOST.pub
mv $HOST-cert.pub $DESTINATION_PATH

echo -e "\nThe certificates can be found here: $DESTINATION_PATH/$HOST\n"