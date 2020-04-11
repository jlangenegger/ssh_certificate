## CA Setup

## Certificate-based SSH authentication
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
On CA, use ssh-keygen to create a host_ca as well a user_ca key pair.  
Create a folder to savely store the keys:
```bash
[root@ca:~]# mkdir /etc/ssh_ca
[root@ca:~]# chmod 700 /etc/ssh_ca
```
### host_ca
Use ssh-keygen to create the host_ca key pair.
```bash
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

### user_ca
Use ssh-keygen to create the user_ca key pair.
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