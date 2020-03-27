#!/bin/bash

USER=''
KEYNUM='1'
DURATION='1'

# flie names of the certifiactes
USER_CERTIFICATE='../user_ca'
SERVER_CERTIFICATE='../host_ca'

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

# tar certificate as well as the host public key
tar -cf "$USER.tar" "$USER-cert.pub" "$SERVER_CERTIFICATE.pub"

# move created key to key folder
mv "$USER.tar" "/home/ca1/"

# remove key, keep certificate
rm "$USER-cert.pub"
rm $USER