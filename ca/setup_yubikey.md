# Setup Yubikey to be used for signing the certificates

## install libraries that are later used
Let’s install some tools:
```bash
apt-get install yubikey-personalization yubico-piv-tool opensc-pkcs11 pcscd
```

## change default pins and mgt key of yubikey
Then prepare the PIV applet in the YubiKey NEO.
```bash
yubikey_id=ca1_host
key=`dd if=/dev/random bs=1 count=24 2>/dev/null | hexdump -v -e '/1 "%02X"'`
echo $key > ssh-$yubikey_id-key.txt
pin=`dd if=/dev/random bs=1 count=6 2>/dev/null | hexdump -v -e '/1 "%u"'|cut -c1-6`
echo $pin > ssh-$yubikey_id-pin.txt
puk=`dd if=/dev/random bs=1 count=6 2>/dev/null | hexdump -v -e '/1 "%u"'|cut -c1-8`
echo $puk > ssh-$yubikey_id-puk.txt

yubico-piv-tool -a set-mgm-key -n $key
yubico-piv-tool -k $key -a change-pin -P 123456 -N $pin
yubico-piv-tool -k $key -a change-puk -P 12345678 -N $puk
```

## generate RSA private keys for SSH Host CA
Then generate a RSA private key for the SSH Host CA, and generate a dummy X.509 certificate for that key. The only use for the X.509 certificate is to make PIV/PKCS#11 happy — they want to be able to extract the public-key from the smartcard, and do that through the X.509 certificate.

```bash
openssl genrsa -out ssh-$yubikey_id-ca-key.pem 2048
openssl req -new -x509 -batch -key ssh-$yubikey_id-ca-key.pem -out ssh-$yubikey_id-ca-crt.pem
```

You import the key and certificate to the PIV applet as follows:
```bash
yubico-piv-tool -k $key -a import-key -s 9c < ssh-$yubikey_id-ca-key.pem
yubico-piv-tool -k $key -a import-certificate -s 9c < ssh-$yubikey_id-ca-crt.pem
```
Extract the public-key for the CA:
```bash
gnu=arm-linux-gnueabihf # used for raspberry
gnu=x86_64-linux-gnu # used for debian

ssh-keygen -D /usr/lib/$gnu/opensc-pkcs11.so -e > ssh-$yubikey_id-ca-key.pub
```

Sign some host keys using the CA, and to configure the hosts' sshd to use them.
```bash
gnu=arm-linux-gnueabihf # used for raspberry
gnu=x86_64-linux-gnu # used for debian

h=host.example.com
scp root@$h:/etc/ssh/ssh_host_rsa_key.pub .
gpg-connect-agent "SCD KILLSCD" "SCD BYE" /bye
ssh-keygen -D /usr/lib/$gnu/opensc-pkcs11.so -s ssh-$yubikey_id-ca-key.pub -I $h -h -n $h -V +52w ssh_host_rsa_key.pub
scp ssh_host_rsa_key-cert.pub root@$h:/etc/ssh/
```