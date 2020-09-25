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
PATH_TO_README="$SCRIPTPATH/CLIENT.md"

# user input
GIT_USER=''
DURATION='-1m:+1w'
PRINCIPALS=''
FILE=''

print_usage() {
    echo "gen_client_cert -g git_user [-f file] -V validity_interval -n principals"
}

set -e # exit on any error

while getopts g:f:V:n:h option
do
case "${option}"
in
g) GIT_USER=${OPTARG} ;;
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
LOADFILE=0
if [ "$GIT_USER" == "" ]; then
    print_usage
    exit 1;
fi
if [ "$FILE" != "" ]; then
    LOADFILE=1
fi

################################################################################
# preparations
################################################################################
# create Certificate ID
CERT_ID="$GIT_USER-$(date +%s)"
KEYS="$GIT_USER.keys"

WORK=$SCRIPTPATH/../$CERT_ID
mkdir $WORK # is used to store intermediate files
mkdir $WORK/tar # is used to copy all relevant file to

mkdir -p $DESTINATION_PATH

################################################################################
# load keys
################################################################################
# laod certificates
if [ $LOADFILE == 1 ]; then
    cp $FILE $WORK/$KEYS
else
    wget -q -O $WORK/$KEYS https://github.com/$KEYS
fi

################################################################################
# sign keys
################################################################################
# iterate through all keys and sign them
KEYNUM=1
while read line; do
    CERT_ID_KEYNUM="$CERT_ID-$KEYNUM"

    echo "$line" >> $WORK/$CERT_ID_KEYNUM

    ssh-keygen -D $PATH_TO_YKCS11 -s $PATH_TO_CERTIFICATE -I $CERT_ID_KEYNUM -n $PRINCIPALS -V $DURATION $WORK/$CERT_ID_KEYNUM
    mv $WORK/$CERT_ID_KEYNUM-cert.pub $WORK/tar

    KEYNUM=$(( $KEYNUM + 1 ))
done < $WORK/$KEYS

# copy the public key and README.md to tar
cp $PATH_TO_README $WORK/tar/README.md

################################################################################
# tar certificates, public key and README and do clean up
################################################################################
tar -cf $DESTINATION_PATH/$CERT_ID.tar -C $WORK/tar .
rm -r $WORK

echo -e "\nThe certificates can be found here: $DESTINATION_PATH/$CERT_ID.tar\n"