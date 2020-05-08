# Certificate Authority
For the purposes of this repository, let’s consider three systems:
* Certification Authority
  * System name “ca.netdef.org“
  * Will host our Certification Authority
* Server
  * System name “server.netdef.org“
  * Will function as an SSH server
* Client 
  * System name "client.netdef.org"
  * Will function as an SSH client

## Sign client's public keys
To sign client's public keys there is the script `generate_client_certificate.sh` to simplify the procedure.  
The scripts does have the following options:
* -g
  * This takes a github user name as an argument and generates a certificate for each key stored in github.
* -f
  * Instead of the github user name, one can provide a file that contains all the keys.
* -V
  * Add the validity period of a certificate in number of days.
  * Per default a certificate is valid for 7 days.
  * Having 0 as a validity period means that the certificate is valid forever.
* -n
  * This flag restricts the certificate to a list of pricipals that the client is allowd to log in.

The output of `generate_client_certificate.sh` is a .tar archive that contains the certificate, the public key that is used to authenticate servers as well as an instruction to install the certificate on the client's machine. It is stored at `/home/ca1/`.

# Prepare CA
## Prepare Yubikey
### install libraries that are later used
Let’s install some tools:
```bash
apt-get install yubikey-personalization yubico-piv-tool opensc-pkcs11 pcscd
```

### change default pins and management key of yubikey
Then prepare the PIV applet in the YubiKey NEO.
```bash
YUBIKEYNUM=1
key=`dd if=/dev/random bs=1 count=24 2>/dev/null | hexdump -v -e '/1 "%02X"'`
echo $key > ssh-$YUBIKEYNUM-key.txt
pin=`dd if=/dev/random bs=1 count=6 2>/dev/null | hexdump -v -e '/1 "%u"'|cut -c1-6`
echo $pin > ssh-$YUBIKEYNUM-pin.txt
puk=`dd if=/dev/random bs=1 count=6 2>/dev/null | hexdump -v -e '/1 "%u"'|cut -c1-8`
echo $puk > ssh-$YUBIKEYNUM-puk.txt

yubico-piv-tool -a set-mgm-key -n $key
yubico-piv-tool -k $key -a change-pin -P 123456 -N $pin
yubico-piv-tool -k $key -a change-puk -P 12345678 -N $puk
```

### generate RSA private keys for SSH Host CA
Then generate a RSA private key for the SSH Host CA, and generate a dummy X.509 certificate for that key. The only use for the X.509 certificate is to make PIV/PKCS#11 happy. They want to be able to extract the public-key from the smartcard, and do that through the X.509 certificate.

```bash
openssl genrsa -out ssh-ca-$YUBIKEYNUM-key.pem 2048
openssl req -new -x509 -batch -key ssh-ca-$YUBIKEYNUM-key.pem -out ssh-ca-$YUBIKEYNUM-cert.pem
```

### import keys to yubikey
You import the key and certificate to the PIV applet as follows:
```bash
yubico-piv-tool -k $key -a import-key -s 9c < ssh-ca-$YUBIKEYNUM-key.pem
yubico-piv-tool -k $key -a import-certificate -s 9c < ssh-ca-$YUBIKEYNUM-cert.pem
```

### extract public key
Extract the public key for the CA:
```bash
ARCH_GNU=arm-linux-gnueabihf # used for raspberry
ARCH_GNU=x86_64-linux-gnu # used for debian

ssh-keygen -D /usr/lib/$ARCH_GNU/opensc-pkcs11.so -e > ssh-ca-$YUBIKEYNUM-key.pub
```

## Sign server's RSA key
```bash
ARCH_GNU=arm-linux-gnueabihf # used for raspberry
ARCH_GNU=x86_64-linux-gnu # used for debian

ssh-keygen  -D /usr/lib/$ARCH_GNU/opensc-pkcs11.so
            -s ssh-ca-$YUBIKEYNUM-key.pub
            -I server_name \
            -h \
            -n server.netdef.org \
            -V +52w \
            /etc/ssh-ca/ssh_host_rsa_key.pub
```
Options explanation:
* -D
  * is used to access the yubikey
* -s
  * provides the public certificate to access the yubikey
* -I server_name
  * The key identifier to include in the certificate.
* -h
  * Generate a host certificate (instead of a user certificate)
* -n server.netdef.org
  * The principal names to include in the certificate.
  * For host certificates this is a list of all names that the system is known by.
  * Note: Use the unqualified names carefully here in organizations where hostnames are not unique (ca.netdef.org vs. ca.dev.netdef.org)
* -V +52w
  * The validity period.
  * For host certificates, you’ll probably want them pretty long lived.
  * This setting sets the validity period from now until 52 weeks hence.
* /etc/ssh-ca/ssh_host_rsa_key.pub
  * The path to the host RSA public key to sign.
  * Our signed host key certificate will be /etc/ssh-ca/ssh_host_rsa_key-cert.pub.

## Sign client's RSA key
```bash
ARCH_GNU=arm-linux-gnueabihf # used for raspberry
ARCH_GNU=x86_64-linux-gnu # used for debian

ssh-keygen  -D /usr/lib/$ARCH_GNU/opensc-pkcs11.so
            -s ssh-ca-$YUBIKEYNUM-key.pub
            -I client_name \
            -n root \
            -V +24h \
            /etc/ssh_ca/id_rsa.pub
```

Options explanation:
* -D
  * is used to access the yubikey
* -s
  * provides the public certificate to access the yubikey
* -I client_name
  * The key identifier to include in the certificate.
* -n root
  * The principal names to include in the certificate.
  * For client certificates this is a list of all users that the system is allowed to log in.
* -V +24h
  * The validity period.
  * For client certificates, you’ll probably want them short lived.
  * This setting sets the validity period from now until 24 hours.
  * One an SSH session is authenticated the certificate can safely expire without impacting the established session.
* /etc/ssh_ca/id_rsa.pub
  * The name of the host RSA public key to sign.
  * Our signed host key (certificate) will be /etc/ssh_ca/ssh_host_rsa_key-cert.pub.