# Certificate-based SSH authentication

Certificate-based SSH authentication is superior to SSH keys in many ways:

* SSH certificates intrinsically possess a validity period before and after which they are invalid for providing authentication.
* SSH certificates can be embedded with SSH restrictions that limit:
  * Who can use the certificate
  * The list of available SSH features (X11Forwarding, AgentForwarding, etc)
  * Which SSH client machines can use the certificate
  * Commands that can be run via SSH

**The documentation can be found on [wiki.netdef.org](https://wiki.netdef.org/display/NET/Certificate-based+SSH+authentication).**