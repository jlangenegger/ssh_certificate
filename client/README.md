# Client Setup
There are two different things needed to setup the certificate authentification.
* user certificates: 
There are N user certifiactes, one for each public key provided for signing.
```bash
helloworld-1588929718-1-cert.pub
helloworld-1588929718-2-cert.pub
...
helloworld-1588929718-N-cert.pub
```
* host certificate public key:
There is one public key to authenticate servers.
```bash
netdef-X.pub
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
* $CERTIFICATES=`$HOME/.ssh/netdef`
* $CONFIG=`$HOME/.ssh/config`
* $KNOWNHOSTS=`$HOME/.ssh/known_hosts`

#### global configuration paths
* `$CERTIFICATES=/etc/ssh/netdef`
* `$CONFIG=/etc/ssh/ssh_config`
* `$KNOWNHOSTS=/etc/ssh/ssh_known_hosts`

### Step 1 - copy all certificates to netdef folder
Copy all certificates that can be found in this tar to the folder `$CERTIFICATES`.
```bash
mkdir -p $CERTIFICATES
cp *cert.pub $CERTIFICATES
```

### Step 2 - edit the config file
Add the following lines to `$CONFIG`. `$CERTIFICATES` must be replaced with the correct path to the folder.
```bash
Host *netdef.org
    CertificateFile `$CERTIFICATES`/helloworld-1588929718-1-cert.pub
    CertificateFile `$CERTIFICATES`/helloworld-1588929718-2-cert.pub
    ...
    CertificateFile `$CERTIFICATES`/helloworld-1588929718-N-cert.pub
```

### Step 3 - edit known hosts file.
Add the following line to `$KNOWNHOSTS` where `netdef-X.pub` must be replaced with the public key stored in netdef-X.pub.
```bash
@cert-authority *.netdef.org `netdef-X.pub`
```