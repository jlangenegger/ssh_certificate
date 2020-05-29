# Client Setup
There are two different things needed to setup the certificate authentification.
* user certificates: 
There are N user certifiactes, one for each public key provided for signing.
```bash
helloworld-1234567890-1-cert.pub
helloworld-1234567890-2-cert.pub
...
helloworld-1234567890-N-cert.pub
```
* host certificate public key:
There is one public key to authenticate servers.
```bash
yubikeyX.pub
```

## tell the SSH daemon about the certificate.
There are two different options to tell the ssh daemon about the certificate: `global` or `user based`.

* `global`: The certificate is valid for each user on the client.
* `user based`: The certificate is valid for one specific user on the client.

To work correctly there are two things that need to be done:
* provide the certificate such that the client can authentificate itsself on the server side. To do so, the ssh daemon needs to knwo where the certificate is stroed and that it is need to login to *.netdef.org
* provide the public host key such that the client can authenticate the host's certificate. This is done by adding a new entrie in the known_hosts file.

The certificates can be installed for a single user or for all users in a machine.
#### user based configuration paths
```bash
SSH_CERTIFICATES=$HOME/.ssh/netdef
SSH_CONFIG=$HOME/.ssh/config
SSH_KNOWNHOSTS=$HOME/.ssh/known_hosts
```

#### global configuration paths
```bash
SSH_CERTIFICATES=/etc/ssh/netdef
SSH_CONFIG=/etc/ssh/ssh_config
SSH_KNOWNHOSTS=/etc/ssh/ssh_known_hosts
```

### Step 1 - copy all certificates to netdef folder
Copy all certificates that can be found in this tar to the folder `$SSH_CERTIFICATES`.
```bash
mkdir -p $SSH_CERTIFICATES
cp *cert.pub $SSH_CERTIFICATES
```

### Step 2 - edit the config file
Add the following lines to `$SSH_CONFIG`. `$SSH_CERTIFICATES` must be replaced with the correct path to the folder.
```bash
Host *.netdef.org
    CertificateFile `$SSH_CERTIFICATES`/helloworld-1234567890-1-cert.pub
    CertificateFile `$SSH_CERTIFICATES`/helloworld-1234567890-2-cert.pub
    ...
    CertificateFile `$SSH_CERTIFICATES`/helloworld-1234567890-N-cert.pub
```

### Step 3 - edit known hosts file.
Add the following line to `$SSH_KNOWNHOSTS` where `yubikeyX.pub` must be replaced with the public key stored in yubikeyX.pub.
```bash
@cert-authority *.netdef.org `yubikeyX.pub`
```