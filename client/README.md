# Client Setup

## tell the SSH daemon about the certificate.
There are two different options to tell the ssh daemon about the certificate: `global` or `user based`.

* `global`: The certificate is valid for each user on the client.
* `user based`: The certificate is valid for one specific user on the client.

To work correctly there are two things that need to be done:
* provide the public host key such that the client can authenticate the hosts. THis is done by adding a new entrie in the known_hosts file.
* provide the certificate such that the client can authentificate itsself on the server side. To do so, the ssh daemon needs to no where the certificate is stroed and that it is need to login to *.netdef.org


There is a script to configure those options called: `install_user_certificate.sh`. To run the script enter the following command:
```bash
[user@client:~] bash install_user_certificate.sh
```

### user based configuration paths
* certificates: `$HOME/.ssh/netdef`
* known hosts: `$HOME/.ssh/known_hosts`
* config: `$HOME/.ssh/config`

### global configuration paths
* certificates: `/etc/ssh/netdef`
* known hosts: `/etc/ssh/ssh_known_hosts`
* config: `/etc/ssh/ssh_config`