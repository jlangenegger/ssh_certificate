#!/bin/bash

################################################################################
# global variables
################################################################################
# settings
PATH_TO_CERTIFICATES='/etc/ssh_ca'
CLIENT_CERTIFICATES=( 'client_ca-1' 'client_ca-2' )
HOST_CERTIFICATES=( 'host_ca-1' 'host_ca-2' )

DESTINATION_PATH='/home/ca1'

# user input
GIT_USER=''
DURATION='1W'
PRINCIPALS=''
FILE=''

print_usage() {
    echo "gen_client_cert [-g git_user] [-f file] [-V duration_of_certificates_in_days] [-n principals]"
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
# prepare files
################################################################################
# create Certificate ID
CERT_ID="$GIT_USER-$(date +%s)"
WORK="$CERT_ID-tmp"
KEYS="keys.pub"

mkdir $WORK # is used to store intermediate files
cd $WORK

mkdir tar # is used to copy all relevant file to

echo "#!/bin/bash
set -e # exit on any error

PATH_SSH=\"\$HOME/.ssh\"
PATH_CERTIFICATES=\"\$PATH_SSH/netdef\"
PATH_KNOWN_HOSTS=\"\$PATH_SSH/known_hosts\"
PATH_CONFIG=\"\$PATH_SSH/config\"

# path to certifiacte folder
echo -e \"Enter folder in which to save the certificates (\$PATH_CERTIFICATES): \\c\"
read maininput
if [ \"\$maininput\" != \"\" ]; then
    PATH_CERTIFICATES=\$maininput
fi

# path to known hosts file
echo -e \"Path to know_hosts file (\$PATH_KNOWN_HOSTS): \\c\"
read maininput
if [ \"\$maininput\" != \"\" ]; then
    PATH_KNOWN_HOSTS=\$maininput
fi

# path to config file
echo -e \"Path to config file (\$PATH_CONFIG): \\c\"
read maininput
if [ \"\$maininput\" != \"\" ]; then
    PATH_CONFIG=\$maininput
fi


mkdir -p \$PATH_CERTIFICATES

echo \"Host *.netdef.org\" >> \$PATH_CONFIG

### client certificates

### host certificates
" > tar/install_user_certificate.sh



# laod certificates
if [ $LOADFILE == 1 ]; then
    cp $FILE $KEYS
else
    wget -q -O $KEYS https://github.com/$GIT_USER.keys
fi

KEYNUM=1
while read line; do
    CERT_ID_KEYNUM="$CERT_ID-$KEYNUM"
    
    CERTNUM=1
    for CERT in ${CLIENT_CERTIFICATES[@]}; do
        CERT_ID_KEYNUM_CERTNUM="$CERT_ID_KEYNUM-$CERTNUM"
        
        echo "$line" >> $CERT_ID_KEYNUM_CERTNUM
        ssh-keygen -s "$PATH_TO_CERTIFICATES/$CERT" -I $CERT_ID_KEYNUM_CERTNUM -n "$PRINCIPALS" -V +$DURATION "$CERT_ID_KEYNUM_CERTNUM"

        # copy signed certificate to tar folder
        mv "$CERT_ID_KEYNUM_CERTNUM-cert.pub" tar/

        LINE="chmod 400 \$PATH_CERTIFICATES/$CERT_ID_KEYNUM_CERTNUM-cert.pub"
        sed -i "/^### client*/a $LINE" tar/install_user_certificate.sh

        LINE="cp $CERT_ID_KEYNUM_CERTNUM-cert.pub \$PATH_CERTIFICATES"
        sed -i "/^### client*/a $LINE" tar/install_user_certificate.sh
        
        LINE="echo \"    CertificateFile \$PATH_CERTIFICATES/$CERT_ID_KEYNUM_CERTNUM-cert.pub\" >> \$PATH_CONFIG"
        sed -i "/^### client*/a $LINE" tar/install_user_certificate.sh
        
        CERTNUM=$(( $CERTNUM + 1 ))
    done

    KEYNUM=$(( $KEYNUM + 1 ))
done < $KEYS

# copy all hosts public key to tar file
for CERT in ${HOST_CERTIFICATES[@]}; do
    LINE="echo \"@cert-authority *.netdef.org `cat "$PATH_TO_CERTIFICATES/$CERT.pub"`\" >> \$PATH_KNOWN_HOSTS"
    sed -i "/^### host*/a $LINE" tar/install_user_certificate.sh
done

cp "../../client/README.md" "tar/README.md"


# tar certificate as well as the host public key and script to install the key
tar -cf "$DESTINATION_PATH/$CERT_ID.tar" -C "tar" .

cd ..

rm -r $WORK

echo -e "\nThe certificates can be found here: $DESTINATION_PATH/$CERT_ID.tar\n"