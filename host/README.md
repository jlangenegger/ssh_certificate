# Host Setup
To enable certificate based login on a host, the signed public rsa key `ssh_host_rsa_key.pub` is needed.
* host certificate
```bash
ssh_host_rsa_key-cert.pub
```

## Step 1 - Host Certifiacte
To tell the SSH daemon about the certificate add the following configuration lines to the file `/etc/ssh/sshd_config` 
The server uses this certificate to identify its-self as a trusted server.  
```bash
### Host certificate
HostCertificate /etc/ssh/ssh_host_rsa_key-cert.pub
```

## Step 2 - Trust User CA Certificate
Add the config lines to the file `/etc/ssh/sshd_config` to tell the SSH daemon about the client_ca.pub key.  
This configures the server to trust all certifactes the are signed by our CA.  
```bash
### User CA certificate
TrustedUserCAKeys /etc/ssh/client_ca.pub
```

## Step 3 - Principals
Now, we'll configure one of our servers to accept only certain principals. To do so, add this line to `/etc/ssh/sshd_config`
```bash
### Auth Principals
AuthorizedPrincipalsFile /etc/ssh/auth_principals/%u
```
Then we need to populate the principals file:
```bash
mkdir /etc/ssh/auth_principals
echo -e 'server.netdef.org\nroot-everywhere' > /etc/ssh/auth_principals/root
```
This allows to all users to loggin as root that have either `server.netdef.org` or `root-everywhere` specified in the list of principals within their certificate.  

You can control access to any other local user by creating the coresponding files under `/etc/ssh/auth_principals`.

## Step 4 - Restart SSH
**Restart SSH to apply all the changes!**