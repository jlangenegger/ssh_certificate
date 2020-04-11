#!/bin/bash

set -e # exit on any error

# flie names of the certifiactes
PATH_TO_CERTIFICATES='/etc/ssh_ca/'
USER_CERTIFICATE='client_ca'
HOST_CERTIFICATE='host_ca'

DESTINATION_PATH='/home/ca1'

# user input
USER=''
FILE=''
CERT_ID=''
DURATION='0'
PRINCIPALS=''

print_usage() {
    echo "gen_client_cert [-g git_user] [-f file] [-I cert_id] [-V duration_of_certificates_in_days] [-n principals]"
}

while getopts g:f:I:V:n:h option
do
case "${option}"
in
g) USER=${OPTARG} ;;
f) FILE=${OPTARG} ;;
I) CERT_ID=${OPTARG} ;;
V) DURATION=${OPTARG} ;;
n) PRINCIPALS=${OPTARG} ;;
h) print_usage; 
   exit 1 ;;
*) print_usage; 
   exit 1 ;;
esac
done

# generate CERT_ID if not provided

# load certificate from file or git
if [ "$USER" != "" ]; then
    # create CERT_ID
    CERT_ID="$USER-$(date +%Y_%m_%d_%H_%M)"
    
    # load ssh key from github
    wget -q -O $CERT_ID https://github.com/$USER.keys | sed -n $KEYNUM'p'

elif [ $FILE != "" ]; then
    # check if CERT_ID was provided
    if [ "$CERT_ID" == "" ]; then
        print_usage
        exit 1;
    fi

    # load ssh key from file
    echo `cat $FILE` >> $CERT_ID
else
    # exit if neither git or file was given
    print_usage
    exit 1;
fi

echo $CERT_ID
echo $PRINCIPALS

# sign key with USER_CERTIFICATE
ssh-keygen -s "$PATH_TO_CERTIFICATES/$USER_CERTIFICATE" -I $CERT_ID -n "$PRINCIPALS" -V +$DURATION'd' $CERT_ID
ssh-keygen -L -f $CERT_ID-cert.pub

# generate installation script for client
# echo "To work properly the SSH certificate must have the same name as the private/public key with the additional ending -cert.pub"
echo "#!/bin/bash

set -e # exit on any error

CERT_ID=\"$CERT_ID-cert.pub\"
PATH_CERT=\"\$HOME/.ssh/id_rsa-cert.pub\"
PATH_KNOWN_HOSTS=\"\$HOME/.ssh/known_hosts\"

echo -e \"Enter file in which to save the certificate (\$PATH_CERT): \\c\"
read maininput
if [ \"\$maininput\" != \"\" ]; then
    PATH_CERT=\$maininput
fi

echo -e \"Path to know_hosts file (\$PATH_KNOWN_HOSTS): \\c\"
read maininput
if [ \"\$maininput\" != \"\" ]; then
    PATH_KNOWN_HOSTS=\$maininput
fi

cp \$CERT_ID \$PATH_CERT
echo \"@cert-authority *.netdef.org \`cat $HOST_CERTIFICATE.pub\`\">>\"\$PATH_KNOWN_HOSTS\"

echo \"To apply certificate: RESTART SSH DAEMON!\"

" > install_user_certificate.sh



# copy all the necessary files to a folder to tar
mkdir -p $DESTINATION_PATH/$CERT_ID
cp "$PATH_TO_CERTIFICATES/$HOST_CERTIFICATE.pub" $DESTINATION_PATH/$CERT_ID
cp "install_user_certificate.sh" $DESTINATION_PATH/$CERT_ID
cp $CERT_ID-cert.pub $DESTINATION_PATH//$CERT_ID
cp "../client/README.md" "$DESTINATION_PATH/$CERT_ID/README.md"

# tar certificate as well as the host public key and script to install the key
tar -cf "$DESTINATION_PATH/$CERT_ID.tar" -C "$DESTINATION_PATH/$CERT_ID" .

# clean up
rm -rf $DESTINATION_PATH/$CERT_ID
rm install_user_certificate.sh
rm $CERT_ID

echo -e "\nThe certificate can be found here: $DESTINATION_PATH/$CERT_ID.tar\n"
