#!/bin/bash

USER=''
KEYNUM='1'
DURATION='1'

# flie names of the certifiactes
USER_CERTIFICATE='../user_ca'
SERVER_CERTIFICATE='../host_ca'

DESTINATION_PATH='/home/ca1'

print_usage() {
    echo "gen_client_cert [-u git_user] [-k key_number_in_git] [-d duration_of_certificates_in_days]"
}

while getopts u:d:k:h option
do
case "${option}"
in
u) USER=${OPTARG} ;;
d) DURATION=${OPTARG} ;;
k) KEYNUM=${OPTARG} ;;
h) print_usage; 
   exit 1 ;;
*) print_usage; 
   exit 1 ;;
esac
done

if [ "$USER" == "" ]; then 
    echo "provide git user!"
    exit 1;
fi

# load ssh key from github
wget -q -O $USER https://github.com/$USER.keys | sed -n $KEYNUM'p'

# sign key with USER_CERTIFICATE
ssh-keygen -s $USER_CERTIFICATE -I $USER -n root -V +$DURATION'd' $USER

# copy all the necessary files to a folder to tar
rm "$USER"
rm -rf $DESTINATION_PATH/$USER
mkdir $DESTINATION_PATH/$USER
mv $USER-cert.pub $DESTINATION_PATH/$USER
cp $SERVER_CERTIFICATE.pub $DESTINATION_PATH/$USER
cp "install_user_certificate.sh" $DESTINATION_PATH/$USER
sed -i "3iCERT='$USER-cert.pub'" $DESTINATION_PATH/$USER/install_user_certificate.sh

# tar certificate as well as the host public key and script to install the key
tar -cf "$DESTINATION_PATH/$USER.tar" -C $DESTINATION_PATH/$USER .
rm -rf $DESTINATION_PATH/$USER
