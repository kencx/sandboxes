#!/usr/bin/bash

set -euxo pipefail

# PASSWORD=$(/usr/bin/openssl passwd -crypt 'vagrant')

# vagrant box specification
/usr/bin/useradd --comment 'Vagrant User' --create-home --user-group vagrant
echo -e 'vagrant\nvagrant' | /usr/bin/passwd vagrant
# echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10_vagrant
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10_vagrant
/usr/bin/chmod 0440 /etc/sudoers.d/10_vagrant
/usr/bin/systemctl start sshd.service
