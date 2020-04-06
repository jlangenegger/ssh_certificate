#!/bin/bash
USER=''
KEYNUM='1'
DURATION='1'
FILE=''

# flie names of the certifiactes
PATH_TO_CERTIFICATES='../'
USER_CERTIFICATE='user_ca'
HOST_CERTIFICATE='host_ca'

DESTINATION_PATH='/home/ca1'

print_usage() {
    echo "gen_client_cert [-u git_user] [-f file] [-k key_number_in_git] [-d duration_of_certificates_in_days]"
}

while getopts u:d:k:f:h option
do
case "${option}"
in
u) USER=${OPTARG} ;;
d) DURATION=${OPTARG} ;;
k) KEYNUM=${OPTARG} ;;
f) FILE=${OPTARG} ;;
h) print_usage; 
   exit 1 ;;
*) print_usage; 
   exit 1 ;;
esac
done

if [ "$USER" == "" ]; then 
    print_usage
    exit 1;
fi

# prepare variables
CERT_ID="$USER-$(date +%Y_%m_%d_%H_%M)"

# load certificate from file or git
if [ "$FILE" == "" ]; then
    # load ssh key from github
    wget -q -O $CERT_ID https://github.com/$USER.keys | sed -n $KEYNUM'p'
else
    # load ssh key from file
    echo `cat $FILE` >> $CERT_ID
fi

# sign key with USER_CERTIFICATE
ssh-keygen -s "$PATH_TO_CERTIFICATES/$USER_CERTIFICATE" -I $USER -n root -V +$DURATION'd' $CERT_ID
ssh-keygen -L -f $CERT_ID-cert.pub

# generate installation script for client
echo "#!/bin/bash
cp $CERT_ID-cert.pub ~/.ssh/id_rsa-cert.pub
echo \"@cert-authority *.netdef.org \`cat $HOST_CERTIFICATE.pub\`\" >> ~/.ssh/known_hosts
echo \"To apply certificate: RESTART SSH DAEMON!\"" > install_user_certificate.sh



# copy all the necessary files to a folder to tar
mkdir -p $DESTINATION_PATH/$USER/$CERT_ID
cp "$PATH_TO_CERTIFICATES/$HOST_CERTIFICATE.pub" $DESTINATION_PATH/$USER/$CERT_ID
cp "install_user_certificate.sh" $DESTINATION_PATH/$USER/$CERT_ID
cp $CERT_ID-cert.pub $DESTINATION_PATH/$USER/$CERT_ID
cp "README_client.md" "$DESTINATION_PATH/$USER/$CERT_ID/README.md"

# tar certificate as well as the host public key and script to install the key
tar -cf "$DESTINATION_PATH/$USER/$CERT_ID.tar" -C $DESTINATION_PATH/$USER/$CERT_ID .

# clean up
rm -rf $DESTINATION_PATH/$USER/$CERT_ID
rm install_user_certificate.sh
rm $USER*
