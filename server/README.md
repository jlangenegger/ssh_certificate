# Server setup

## Certificate-based SSH authentication
For the purposes of that repository, let’s consider three systems:
* Certification Authority
  * System name “ca.netdef.org“
  * Will host our Certification Authority
* Server
  * System name “server.netdef.org“
  * Will function as an SSH server
* Client 
  * System name "client.netdef.org"
  * Will function as an SSH client


## Sign the server's RSA key
### Copy server's RSA key from server.netdef.org to CA
```bash
[root@server:~]# ls /etc/ssh/ssh_host_rsa*
-rw------- 1 root root 1823 Sep 26 12:47 /etc/ssh/ssh_host_rsa_key
-rw-r--r-- 1 root root  399 Sep 26 12:47 /etc/ssh/ssh_host_rsa_key.pub
```
Copy `/etc/ssh/ssh_host_rsa_key.pub` to the CA server and sign it.

### Copy host's certifacte from the CA back to server.netdef.org
```bash
[root@server:~]# ls /etc/ssh/ssh_host_rsa*
-rw------- 1 root root 1823 Sep 26 12:47 /etc/ssh/ssh_host_rsa_key
-rw------- 1 root root 1823 Sep 26 12:47 /etc/ssh/ssh_host_rsa_key-cert.pub
-rw-r--r-- 1 root root  399 Sep 26 12:47 /etc/ssh/ssh_host_rsa_key.pub
```

## Tell the SSH daemon about the certificate.
### HostCertificate
The server uses this certificate to identify its-self as a trusted server.  
To tell the SSH daemon about the certificate add the following configuration lines to the file `/etc/ssh/sshd_config` 
```bash
### Host certificate
HostCertificate /etc/ssh/ssh_host_rsa_key-cert.pub
```

### TrustedUserCAKeys
This forces the server to trust all certifactes the are signed with the user_ca key.  
Copy the user_ca.pub to `root@server:/etc/ssh/user_ca.pub`  
Add the config lines to the file `/etc/ssh/sshd_config` to tell the SSH daemon about the user_ca.pub key.  
```bash
### User CA certificate
TrustedUserCAKeys /etc/ssh/user_ca.pub
```