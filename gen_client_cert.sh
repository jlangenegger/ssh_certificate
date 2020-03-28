#!/bin/bash
USER=''
KEYNUM='1'
DURATION='1'

# flie names of the certifiactes
PATH_TO_CERTIFICATES='../'
USER_CERTIFICATE='user_ca'
HOST_CERTIFICATE='host_ca'

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

# prepare variables
CERT_ID="$USER-$(date +%Y_%m_%d_%H_%M)"

# load ssh key from github
wget -q -O $CERT_ID https://github.com/$USER.keys | sed -n $KEYNUM'p'

# sign key with USER_CERTIFICATE
ssh-keygen -s "$PATH_TO_CERTIFICATES/$USER_CERTIFICATE" -I $USER -n root -V +$DURATION'd' $CERT_ID

# generate installation script for client
echo "#!/bin/bash
cp $CERT_ID-cert.pub ~/.ssh
cp $HOST_CERTIFICATE.pub ~/.ssh
echo \"@cert-authority *.netdef.org \`cat ~/.ssh/$HOST_CERTIFICATE.pub\`\" >> ~/.ssh/known_hosts
echo \"To apply certificate: RESTART SSH DAEMON!\"" > install_user_certificate.sh



# copy all the necessary files to a folder to tar
mkdir -p $DESTINATION_PATH/$USER/$CERT_ID
cp "$PATH_TO_CERTIFICATES/$HOST_CERTIFICATE.pub" $DESTINATION_PATH/$USER/$CERT_ID
cp "install_user_certificate.sh" $DESTINATION_PATH/$USER/$CERT_ID
cp $CERT_ID-cert.pub $DESTINATION_PATH/$USER/$CERT_ID

# tar certificate as well as the host public key and script to install the key
tar -cf "$DESTINATION_PATH/$USER/$CERT_ID.tar" -C $DESTINATION_PATH/$USER/$CERT_ID .

# clean up
rm -rf $DESTINATION_PATH/$USER/$CERT_ID
rm install_user_certificate.sh
rm $USER*
