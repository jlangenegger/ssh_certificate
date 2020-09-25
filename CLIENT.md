# Step 1 - Configuration paths
There are two different options to tell SSH about the certificate: 'user based' (recommended)  or 'global':

* 'user based': The certificate is valid for one specific user on the client.
    ```bash
    SSH_CERTIFICATES=$HOME/.ssh/netdef
    SSH_CONFIG=$HOME/.ssh/config
    SSH_KNOWNHOSTS=$HOME/.ssh/known_hosts
    ```

* 'global': The certificate is valid for each user on the client.
    ```bash
    SSH_CERTIFICATES=/etc/ssh/netdef
    SSH_CONFIG=/etc/ssh/ssh_config
    SSH_KNOWNHOSTS=/etc/ssh/ssh_known_hosts
    ```

# Step 2 - Copy all certificates to netdef folder
Copy all certificates that can be found in this folder the folder '$SSH_CERTIFICATES'.
```bash
mkdir -p $SSH_CERTIFICATES
cp *cert.pub $SSH_CERTIFICATES
```

# Step 3 - Edit the config file
Add the following lines to '$SSH_CONFIG'. The name of the certificate 'helloworld-1234567890-X-cert.pub' as well as '$SSH_CERTIFICATES' must be replaced with the correct file name and the correct path to the folder respectively.
```bash
Host *.netdef.org
    CertificateFile `$SSH_CERTIFICATES`/helloworld-1234567890-1-cert.pub
    CertificateFile `$SSH_CERTIFICATES`/helloworld-1234567890-2-cert.pub
    ...
    CertificateFile `$SSH_CERTIFICATES`/helloworld-1234567890-N-cert.pub
```

**For more information visit [wiki.netdef.org](https://wiki.netdef.org/display/NET/Client+Setup)**