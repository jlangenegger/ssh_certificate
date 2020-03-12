# Certificate-based SSH authentication

Certificate-based SSH authentication is superior to SSH keys in many ways:

* SSH certificates intrinsically possess avalidity period before and after which theyare invalid for providing authentication.
* SSH certificates can be embedded with SSH restrictions that limit:
  * Who can use the certificate
  * The list of available SSH features (X11Forwarding, AgentForwarding, etc)
  * Which SSH client machines can use thecertificate
  * Commands that can be run via SSH


## Setup
For the purposes of this document, let’s consider three systems:
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

On ca, use ssh-keygen to create a host CA key pair.

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

## Sign the server's RSA key
### copy key to CA
```bash
[root@server:~]# ls /etc/ssh/ssh_host*
-rw------- 1 root root  513 Sep 26 12:47 /etc/ssh/ssh_host_ecdsa_key
-rw-r--r-- 1 root root  179 Sep 26 12:47 /etc/ssh/ssh_host_ecdsa_key.pub
-rw------- 1 root root 1823 Sep 26 12:47 /etc/ssh/ssh_host_rsa_key
-rw-r--r-- 1 root root  399 Sep 26 12:47 /etc/ssh/ssh_host_rsa_key.pub
```

Copy `/etc/ssh/ssh_host_rsa_key.pub` to the CA server.

### sign key
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
  * The name of the host RSA public key to sign.
  * Our signed host key (certificate) will be /etc/ssh_ca/ssh_host_rsa_key-cert.pub.

### copy certifacte from CA to server
Copy `/etc/ssh_ca/ssh_host_rsa_key-cert.pub` back to the server.  
Copy `/etc/ssh_ca/user_ca.pub` to the server.  
As a destination choose `/etc/ssh/`for both files.  

### tell the SSH daemon about the certificate.
Add the lines to the file `/etc/ssh/sshd_config`.
```bash
### Host certificate
HostCertificate /etc/ssh/ssh_host_rsa_key-cert.pub

### User CA certificate 
TrustedUserCAKeys /etc/ssh/user_ca.pub 
```
Options explanation:
* HostCertificate
  * The server uses this certificate 

* TrustedUserCAKeys
  * This forces the server to trust all certifactes the are signed with the user_ca key.

