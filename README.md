# Certificate-based SSH authentication

Certificate-based SSH authentication is superior to SSH keys in many ways:

* SSH certificates intrinsically possess avalidity period before and after which theyare invalid for providing authentication.
* SSH certificates can be embedded with SSH restrictions that limit:
  * Who can use the certificate
  * The list of available SSH features (X11Forwarding, AgentForwarding, etc)
  * Which SSH client machines can use thecertificate
  * Commands that can be run via SSH


## Setup
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

## Prepare CA
We’re going to need to set up certificates based on both the host and user keys.

On CA, use ssh-keygen to create a host CA key pair.

### host_ca
Use ssh-keygen to create a host CA key pair.

```bash
[root@ca:~]# mkdir /etc/ssh_ca
[root@ca:~]# chmod 700 /etc/ssh_ca
[root@ca:~]# cd /etc/ssh_ca
[root@ca:/etc/ssh_ca]# ssh-keygen -q -b 4096 -f host_ca
Enter passphrase (empty for no passphrase): secretHostPassphrase
Enter same passphrase again: secretHostPassphrase
[root@ca:/etc/ssh_ca]# ls -al
drwx------. 2  root root   38 Mar 12 11:47 .
drwxr-xr-x. 87 root root 8192 Mar 12 11:47 ..
-rw-------. 1  root root 3326 Mar 12 11:47 host_ca
-rw-r--r--. 1  root root  733 Mar 12 11:47 host_ca.pub
```
Options explanation:

* -q
  * This suppresses all output except for that which is necessary.
* -b 4096
  * Creates a key pair where each key is 4096 bits in length
* -f host_ca
  * The name of our certification authority’s host key pair.
  * /etc/ssh_ca/host_ca will contain the private key.
  * /etc/ssh_ca/host_ca.pub will contain the public key.


### client_ca
Use ssh-keygen to create a user CA key pair.
```bash
[root@ca:~]# cd /etc/ssh_ca
[root@ca:/etc/ssh_ca]# ssh-keygen -q -b 4096 -f user_ca
Enter passphrase (empty for no passphrase): secretUserPassphrase
Enter same passphrase again: secretUserPassphrase
[root@ca:/etc/ssh_ca]# ls -al
drwx------. 2  root root   38 Mar 12 11:47 .
drwxr-xr-x. 87 root root 8192 Mar 12 11:47 ..
-rw-------. 1  root root 3326 Mar 12 11:47 host_ca
-rw-r--r--. 1  root root  733 Mar 12 11:47 host_ca.pub
-rw-------. 1  root root 3326 Mar 12 11:59 user_ca
-rw-r--r--. 1  root root  733 Mar 12 11:59 user_ca.pub
```
* -q
  * This suppresses all output except for that which is necessary.
* -b 4096
  * Creates a key pair where each key is 4096 bits in length
* -f host_ca
  * The name of our certification authority’s host key pair.
  * /etc/ssh_ca/user_ca will contain the private key.
  * /etc/ssh_ca/user_ca.pub will contain the public key.

## Sign the server's RSA key
### copy server's RSA key to CA
```bash
[root@server:~]# ls /etc/ssh/ssh_host*
-rw------- 1 root root  513 Sep 26 12:47 /etc/ssh/ssh_host_ecdsa_key
-rw-r--r-- 1 root root  179 Sep 26 12:47 /etc/ssh/ssh_host_ecdsa_key.pub
-rw------- 1 root root 1823 Sep 26 12:47 /etc/ssh/ssh_host_rsa_key
-rw-r--r-- 1 root root  399 Sep 26 12:47 /etc/ssh/ssh_host_rsa_key.pub
```

Copy `/etc/ssh/ssh_host_rsa_key.pub` to the CA server.

### sign server's RSA key
```bash
[root@ca:~]# ssh-keygen -s host_ca \
                        -I server_name \
                        -h \
                        -n server.netdef.org \
                        -V +52w \
                        /etc/ssh_ca/ssh_host_rsa_key.pub
Signed host key ssh_host_rsa_key.pub: id "server.netdef.org" serial 0 for server.netdef.org valid from 2020-03-12T07:46:00 to 2021-03-11T06:46:59
```
Options explanation:
* -s host_ca
  * The file name of the host private key to use for signing.
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
* /etc/ssh_ca/ssh_host_rsa_key.pub
  * The path to the host RSA public key to sign.
  * Our signed host key (certificate) will be /etc/ssh_ca/ssh_host_rsa_key-cert.pub.

### copy host's certifacte from the CA to server.netdef.org
```bash
[root@ca:~]# ls -al /etc/ssh_ca
total 48
drwx------  2 root root 4096 Mar 12 04:32 .
drwxr-xr-x 70 root root 4096 Mar 12 02:42 ..
-rw-------  1 root root 3369 Mar 12 02:43 host_ca
-rw-r--r--  1 root root  734 Mar 12 02:43 host_ca.pub
-rw-r--r--  1 root root  381 Mar 12 04:31 ssh_host_rsa_key.pub
-rw-r--r--  1 root root 2064 Mar 12 04:14 ssh_host_rsa_key-cert.pub
-rw-------  1 root root 3369 Mar 12 02:56 user_ca
-rw-r--r--  1 root root  734 Mar 12 02:56 user_ca.pub
```
### tell the SSH daemon about the certificate.
Copy `/etc/ssh_ca/ssh_host_rsa_key-cert.pub` back to `server.netdef.org:/etc/ssh/`.  
Copy `/etc/ssh_ca/user_ca.pub` to the `server.netdef.org:/etc/ssh/`.  
As a destination choose `/etc/ssh/`for both files.  

Add the config lines to the file `/etc/ssh/sshd_config` to tell the SSH daemon about the certificate.

```bash
[root@ca:~]# echo "
### Host certificate
HostCertificate /etc/ssh/ssh_host_rsa_key-cert.pub

### User CA certificate
TrustedUserCAKeys /etc/ssh/user_ca.pub" >> /etc/ssh/sshd_config
```
Options explanation:
* HostCertificate
  * The server uses this certificate to identify its-self as a trusted server.

* TrustedUserCAKeys
  * This forces the server to trust all certifactes the are signed with the user_ca key.

## Sign the client's RSA key
### copy client's RSA key to CA
```bash
[root@client:~]# ls -al ~/.ssh
total 24
drwxr-xr-x  2 pi   pi   4096 Mar 12 11:11 .
drwxr-xr-x 19 pi   pi   4096 Mar 12 09:21 ..
-rw-------  1 pi   pi   1675 Feb 20 14:19 id_rsa
-rw-r--r--  1 pi   pi    395 Feb 20 14:19 id_rsa.pub
```

Copy `~/.ssh/id_rsa.pub` to the CA server.

### sign client's RSA key
```bash
[root@ca:~]# ssh-keygen -s user_ca \
                        -I client_name \
                        -n root \
                        -V +24h \
                        /etc/ssh_ca/id_rsa.pub
Signed user key /etc/ssh_ca/id_rsa-cert.pub: id "client_name" serial 0 for root valid from 2020-03-12T08:39:00 to 2020-03-13T08:40:37
```
Options explanation:
* -s user_ca
  * The file name of the host private key to use for signing.
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

### copy client's certifacte from the CA to the client
```bash
[root@ca:~]# ls -al /etc/ssh_ca
total 48
drwx------  2 root root 4096 Mar 12 04:32 .
drwxr-xr-x 70 root root 4096 Mar 12 02:42 ..
-rw-------  1 root root 3369 Mar 12 02:43 host_ca
-rw-r--r--  1 root root  734 Mar 12 02:43 host_ca.pub
-rw-r--r--  1 root root  381 Mar 12 04:31 id_rsa.pub
-rw-r--r--  1 root root 2064 Mar 12 04:14 id_rsa-cert.pub
-rw-------  1 root root 3369 Mar 12 02:56 user_ca
-rw-r--r--  1 root root  734 Mar 12 02:56 user_ca.pub
```

### tell the SSH daemon about the certificate.
There are two different options to tell the daemon about the certificate: `global` or `user based`.

#### global
The certificate is valid for each user on the client.  
Copy `/etc/ssh_ca/id_rsa-cert.pub` back to `/etc/ssh/`.  
Copy `/etc/ssh_ca/host_ca.pub` to the `/etc/ssh/`.  
As a destination choose `/etc/ssh/`for both files.  

Add the following lines to the file `/etc/ssh/ssh_known_hosts` to tell the SSH daemon about the certificate.

```bash
[root@client:~]# echo "@cert-authority *.netdef.org `cat /etc/ssh/host_ca.pub`" >> /etc/ssh/ssh_known_hosts
```
#### user based
The certificate is valid for one specific user on the client.  
Copy `/etc/ssh_ca/id_rsa-cert.pub` back to `~/.ssh/`.  
Copy `/etc/ssh_ca/host_ca.pub` to the `~/.ssh/`.  
As a destination choose `~/.ssh/`for both files.  

Add the configuration line to the file `~/.ssh/known_hosts` to tell the SSH daemon about the certificate.

```bash
[root@client:~]# echo "@cert-authority *.netdef.org `cat ~/.ssh/host_ca.pub`" >> ~/.ssh/known_hosts
```

## Revoke SSH Key
To revoke a SSH key of a client, the key needs to be added to the list of revoked_keys.  

**_NOTE:_**  Unfortunately, this needs to be done on each and every server!

### create new revoked keys list
This command creates a new revoked_keys list.
```bash
[root@server:~]# ssh-keygen -kf /etc/ssh/revoked_keys ~/id_rsa.pub
```
To tell the daemon about the new revoked_key list use the following command:
```bash
echo "
### RevokedKeys List
RevokedKeys /etc/ssh/revoked_keys" >> /etc/ssh/sshd_config
```

### add new revoked key
If there is an exisiting revoked_keys list, one can add a key using the following command:
```bash
[root@server:~]# ssh-keygen -ukf  /etc/ssh/revoked_keys ~/id_rsa.pub
```

### test revoked key
To test if a keys has been revoked us the following command
```bash
[root@server:~]# ssh-keygen -Qf /etc/ssh/revoked_keys ~/id_rsa.pub
```


## Trouble shooting
### read certificate
```bash
[root@ca:~]# ssh-keygen -L -f ~/.ssh/id_rsa-cert.pub
/root/.ssh/id_rsa-cert.pub:
        Type: ssh-rsa-cert-v01@openssh.com user certificate
        Public key: RSA-CERT SHA256:I7H1vCxXFUihg6LjKheeXrg1NPr0Ogiz6HeUKUBwXCg
        Signing CA: RSA SHA256:nS3AVpov/OnlpOfAbLTeLDa38NVXyRG/PFpo6jxqwgQ
        Key ID: "user_admin"
        Serial: 0
        Valid: forever
        Principals:
                root
        Critical Options: (none)
        Extensions:
                permit-X11-forwarding
                permit-agent-forwarding
                permit-port-forwarding
                permit-pty
                permit-user-rc
```
### log
```bash
[root@server:~]# tail -f /var/log/auth.log
```