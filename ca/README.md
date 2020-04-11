# CA Setup

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
On CA, use ssh-keygen to create a host_ca as well a client_ca key pair.  
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

### client_ca
Use ssh-keygen to create the client_ca key pair.
```bash
[root@ca:~]# cd /etc/ssh_ca
[root@ca:/etc/ssh_ca]# ssh-keygen -q -b 4096 -f client_ca
Enter passphrase (empty for no passphrase): secretUserPassphrase
Enter same passphrase again: secretUserPassphrase
[root@ca:/etc/ssh_ca]# ls -al
drwx------. 2  root root   38 Mar 12 11:47 .
drwxr-xr-x. 87 root root 8192 Mar 12 11:47 ..
-rw-------. 1  root root 3326 Mar 12 11:47 host_ca
-rw-r--r--. 1  root root  733 Mar 12 11:47 host_ca.pub
-rw-------. 1  root root 3326 Mar 12 11:59 client_ca
-rw-r--r--. 1  root root  733 Mar 12 11:59 client_ca.pub
```

* -q
  * This suppresses all output except for that which is necessary.
* -b 4096
  * Creates a key pair where each key is 4096 bits in length
* -f host_ca
  * The name of our certification authority’s host key pair.
  * /etc/ssh_ca/client_ca will contain the private key.
  * /etc/ssh_ca/client_ca.pub will contain the public key.

## Sign public keys
To sign public keys there is the script `generate_client_certificate.sh` to simplify the procedure.  
The scripts does have the following options:
* -g
  * This takes a github user name as an argument and generates a certificate for each key stored in the github.
* -f
  * Instead of the github user name, one can provide a file that contains all the keys.
* -I
  * If there is no github name, this flag is needed to provide the certificate ID.
* -V
  * Add the validity period of a certificate in number of days.
  * Per default a certificate is valid for 7 days.
  * Having 0 as a validity period means that the certificate is valid forever.
* -n
  * This flag restricts the certificate to a list of pricipals that the client is allowd to log in.

The output of `generate_client_certificate.sh` is a .tar archive that contains the certificate as well as an install script for the client and the host_ca.pub key that is used to authanticate servers from the client side. It is stored at `/home/ca1/`.