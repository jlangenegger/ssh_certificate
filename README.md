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
[root@ca ~]# mkdir /etc/ssh_ca
[root@ca ~]# chmod 700 /etc/ssh_ca
[root@ca ~]# cd /etc/ssh_ca
[root@ca ssh_ca]# ssh-keygen -q -b 4096 -f host_ca
Enter passphrase (empty for no passphrase): secretHostPassphrase
Enter same passphrase again: secretHostPassphrase
[root@ca ssh_ca]# ls -al
total 20
drwx------. 2  root root   38 Mar 12 11:47 .
drwxr-xr-x. 87 root root 8192 Mar 12 11:47 ..
-rw-------. 1  root root 3326 Mar 12 11:47 host_ca
-rw-r--r--. 1  root root  733 Mar 12 11:47 host_ca.pub
```

## client_ca
Use ssh-keygen to create a user CA key pair.
```bash
[root@ca ~]# cd /etc/ssh_ca
[root@ca ssh_ca]# ssh-keygen -q -b 4096 -f user_ca
Enter passphrase (empty for no passphrase): secretUserPassphrase
Enter same passphrase again: secretUserPassphrase
[root@ca ssh_ca]# ls -al
total 20
drwx------. 2  root root   38 Mar 12 11:47 .
drwxr-xr-x. 87 root root 8192 Mar 12 11:47 ..
-rw-------. 1  root root 3326 Mar 12 11:47 host_ca
-rw-r--r--. 1  root root  733 Mar 12 11:47 host_ca.pub
-rw-------. 1  root root 3326 Mar 12 11:59 user_ca
-rw-r--r--. 1  root root  733 Mar 12 11:59 user_ca.pub
```