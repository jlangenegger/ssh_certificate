# Certificate-based SSH authentication

Certificate-based SSH authentication is superior to SSH keys in many ways:

* SSH certificates intrinsically possess avalidity period before and after which theyare invalid for providing authentication.
* SSH certificates can be embedded with SSH restrictions that limit:
  * Who can use the certificate
  * The list of available SSH features (X11Forwarding, AgentForwarding, etc)
  * Which SSH client machines can use thecertificate
  * Commands that can be run via SSH

## Setup
For the purposes of this repository, let’s consider three systems:
* Certification Authority (CA)
  * System name “ca.netdef.org“
  * Will host our Certification Authority
* Host
  * System name “host.netdef.org“
  * Will function as an SSH server
* Client 
  * System name "client.netdef.org"
  * Will function as an SSH client

## Certificates
There are two different certificates.
* client certificate
  * This certificate is stored on the client and is provided to the host during the ssh connection establishment.
  * It is used on the host side to authenticate the clients that try to login.
* host certificate
  * This certificate is stored on the host and is provided to the client during the ssh connection establishment.
  * It is used on the client side to authenticate the host that the client tries to login.

## configuration
To configure the client and the host, there are seperate READMEs:
* (./host/README.md#Host Setup) 
* (./client/README.md#Client Setup)

# Help
### read certificate
```bash
ssh-keygen -L -f ~/.ssh/id_rsa-cert.pub
/root/.ssh/id_rsa-cert.pub:
        Type: ssh-rsa-cert-v01@openssh.com user certificate
        Public key: RSA-CERT SHA256:I7H1vCxXFUihg6LjKheeXrg1NPr0Ogiz6HeUKUBwXCg
        Signing CA: RSA SHA256:nS3AVpov/OnlpOfAbLTeLDa38NVXyRG/PFpo6jxqwgQ
        Key ID: "user_admin"
        Serial: 0
        Valid: forever
        Principals:
                root
        Critical Options: (none)
        Extensions:
                permit-X11-forwarding
                permit-agent-forwarding
                permit-port-forwarding
                permit-pty
                permit-user-rc
```
### log
```bash
[root@host:~]# tail -f /var/log/auth.log
```