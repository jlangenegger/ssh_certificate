# Client Setup

## tell the SSH daemon about the certificate.
There are two different options to tell the ssh daemon about the certificate: `global` or `user based`.

* `global`: The certificate is valid for each user on the client.
* `user based`: The certificate is valid for one specific user on the client.

To work correctly there are two things that need to be done:
* provide the `host_ca.pub` such that the client can authenticate the hosts. Therefor the `host_ca.pub` must be added to the known_hosts file..
* provide the certificate such that the client can authentificate itsself on the server side. To do so, the certificate must be stored in the same folder as the key is and be named the same way.


There is a script to configure those options called: `install_user_certificate.sh`.  

### user based
* certificate: `$HOME/.ssh/id_rsa-cert.pub`
* known hosts: `$HOME/.ssh/known_hosts`

### global
* certificate: `/etc/ssh/ssh_host_rsa_key-cert.pub`
* known hosts: `/etc/ssh/ssh_known_hosts`