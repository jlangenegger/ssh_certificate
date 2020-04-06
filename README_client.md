# Certificate-based SSH authentication
To sucessfully authenticate you need to tell the SSH agent to provide the certificate to the host if you login to *.netdef.org.  

Do do so there are two options:
1) Use the provided script `install_user_certificate.sh`. This scripts installs the certifacte automatically for the user that is logged-in.
2) Install the certificate manually. The steps can be found right below.

---
**NOTE**

To apply the changes you need to manualy restart the ssh deamon!
---

### manually tell the SSH daemon about the certificate.
There are two different options to tell the daemon about the certificate: `global` or `user based`.

#### global
The certificate is valid for each user on the client.  
Copy `id_rsa-cert.pub` back to `/etc/ssh/`.  
Copy `host_ca.pub` to the `/etc/ssh/`.   

Add the following lines to the file `/etc/ssh/ssh_known_hosts` to tell the SSH daemon about the certificate.
```bash
[root@client:~]# echo "@cert-authority *.netdef.org `cat host_ca.pub`" >> /etc/ssh/ssh_known_hosts
```
#### user based
The certificate is valid for one specific user on the client.  
Copy `/etc/ssh_ca/id_rsa-cert.pub` back to `~/.ssh/`.  
Copy `/etc/ssh_ca/host_ca.pub` to the `~/.ssh/`.  
As a destination choose `~/.ssh/`for both files.  

Add the configuration line to the file `~/.ssh/known_hosts` to tell the SSH daemon about the certificate.
```bash
[root@client:~]# echo "@cert-authority *.netdef.org `cat ~host_ca.pub`" >> ~/.ssh/known_hosts
```
