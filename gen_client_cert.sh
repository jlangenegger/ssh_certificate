#!/bin/bash

################################################################################
# global variables
################################################################################
YUBIKEYNUM=1

SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`

PATH_TO_YKCS11="/usr/local/lib/libykcs11.so"
PATH_TO_CERTIFICATE="/etc/ssh-ca/yubikey$YUBIKEYNUM.pub"
DESTINATION_PATH="$HOME/signed_keys"
PATH_TO_README="$SCRIPTPATH/CLIENT.md"

# user input
GIT_USER=''
DURATION='-24h:+1w'
PRINCIPALS=''
FILE=''

print_usage() {
    echo "gen_client_cert -g git_user [-f file] -V validity_interval -n principals"
}

function check_periode {
    if ! [[ "$DURATION" == *":"* ]]; then
        if [[ "$DURATION" == *"+"* ]]; then
            DURATION="-24h:$DURATION"
        else
            DURATION="-24h:+$DURATION"
        fi
    fi
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
check_periode # format duration input

if [ "$GIT_USER" == "" ]; then
    echo -n "Enter username for Github: "
    read GIT_USER
    if [ "$PRINCIPALS" == "" ]; then
        echo -n "Enter principals: "
    else
        echo -n "Enter principals ($PRINCIPALS): "
    fi
    read PRINCIPALS
    echo -n "Enter validity period ($DURATION): "
    read DURATION_USER_INPUT
    if ! [[ "$DUR_IN" == "" ]]; then
        DURATION=$DURATION_USER_INPUT
    fi 

fi

if [ "$PRINCIPALS" == "" ]; then
    echo -n "Enter principals: "
    read PRINCIPALS
    echo -n "Enter validity period ($DURATION): "
    read DURATION_USER_INPUT
    if ! [[ "$DUR_IN" == "" ]]; then
        DURATION=$DURATION_USER_INPUT
    fi 
fi

if [ "$FILE" != "" ]; then
    LOADFILE=1
fi

check_periode # format duration input
################################################################################
# preparations
################################################################################
# create Certificate ID
CERT_ID="$GIT_USER"
KEYS="$GIT_USER.keys"
INFOS="$GIT_USER.infos"

WORK=$SCRIPTPATH/../$CERT_ID
rm -rf $WORK 
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
# print additional infos
################################################################################
if [ "$FILE" == "" ]; then
    wget -q -O $WORK/$GIT_USER "https://api.github.com/users/$GIT_USER"
    GIT_USER_NAME=`cat $WORK/$GIT_USER | jq -r '.name'`
    if [ "$GIT_USER_NAME" == "null" ]; then
        GIT_USER_NAME="-"
    fi
    GIT_USER_COMPANY=`cat $WORK/$GIT_USER | jq -r '.company'`
    if [ "$GIT_USER_COMPANY" == "null" ]; then
        GIT_USER_COMPANY="-"
    fi
    GIT_USER_LOCATION=`cat $WORK/$GIT_USER | jq -r '.location'`
    if [ "$GIT_USER_LOCATION" == "null" ]; then
        GIT_USER_LOCATION="-"
    fi
fi
echo "$GIT_USER: $GIT_USER_NAME, $GIT_USER_COMPANY, $GIT_USER_LOCATION"

################################################################################
# sign keys
################################################################################
# iterate through all keys and sign them
while read line; do
    KEY_SINGLE="SSH_KEY"
    echo "$line" > $WORK/$KEY_SINGLE

    ssh-keygen -D $PATH_TO_YKCS11 -s $PATH_TO_CERTIFICATE -I $CERT_ID -n $PRINCIPALS -V $DURATION $WORK/$KEY_SINGLE

    cat $WORK/$KEY_SINGLE-cert.pub >>  $WORK/tar/NETDEF-cert.pub

done < $WORK/$KEYS

# copy the public key and README.md to tar
cp $PATH_TO_README $WORK/tar/README.md

################################################################################
# tar certificates, public key and README and do clean up
################################################################################
tar -cf $DESTINATION_PATH/$CERT_ID.tar -C $WORK/tar .
rm -r $WORK

echo -e "\nThe certificates can be found here: $DESTINATION_PATH/$CERT_ID.tar\n"
