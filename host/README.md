# Host Setup
To enable certificate based login on a host, the public rsa key `ssh_host_rsa_key.pub` needs to be signed. The resulting certificate is called `ssh_host_rsa_key-cert.pub`. To enable ssh based login two things are required on the host:
* host certificate: `ssh_host_rsa_key-cert.pub`
* CA public key: `netdef-1.pub`

## Step 1 - Host Certifiacte
To tell the SSH daemon about the certificate add the following configuration lines to the file `/etc/ssh/sshd_config`. In addition copy the certificate to the specified location. The host sends this certificate to the client to identify itsself as a trusted host. 
```bash
### Host certificate
HostCertificate /etc/ssh/ssh_host_rsa_key-cert.pub
```

## Step 2 - Trust User CA Certificate
Add the following lines to the file `/etc/ssh/sshd_config` to tell the SSH daemon about the public key to verifiy client certificates. In addition copy the public key to the specified location. The host trusts all certifactes the are signed by our CA.
```bash
### User CA certificate
TrustedUserCAKeys /etc/ssh/netdef-1.pub
```

## Step 3 - Principals
Now, we'll configure one of our hosts to accept only certain principals. To do so, add this line to `/etc/ssh/sshd_config`
```bash
### Auth Principals
AuthorizedPrincipalsFile /etc/ssh/auth_principals/%u
```
Then we need to populate the principals file:
```bash
mkdir /etc/ssh/auth_principals
echo -e 'host.netdef.org\nroot-everywhere' > /etc/ssh/auth_principals/root
```
This allows to all users to loggin as root that have either `host.netdef.org` or `root-everywhere` specified in the list of principals within their certificate.  

You can control access to any other local user by creating the coresponding files under `/etc/ssh/auth_principals`.

## Step 4 - Restart SSH
**Restart SSH to apply all the changes!**