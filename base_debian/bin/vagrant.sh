#!/bin/sh -eux

HOME_DIR="/home/vagrant"
mkdir -m 0700 -p $HOME_DIR/.ssh

INSECURE_KEY_URL="https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub"
wget --no-check-certificate "$INSECURE_KEY_URL" -O "$HOME_DIR"/.ssh/authorized_keys
chown -R vagrant:vagrant $HOME_DIR/.ssh
chmod 0600 $HOME_DIR/.ssh/authorized_keys

# password-less sudo
SUDOERS_FILE=/etc/sudoers.d/vagrant
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > $SUDOERS_FILE
chmod 0440 $SUDOERS_FILE

# turn off reverse dns lookup when ssh-ing
SSHD_CONFIG="/etc/ssh/sshd_config"
# ensure that there is a trailing newline before attempting to concatenate
sed -i -e '$a\' "$SSHD_CONFIG"

USEDNS="UseDNS no"
if grep -q -E "^[[:space:]]*UseDNS" "$SSHD_CONFIG"; then
    sed -i "s/^\s*UseDNS.*/${USEDNS}/" "$SSHD_CONFIG"
else
    echo "$USEDNS" >>"$SSHD_CONFIG"
fi

# disable predictable network interface names and use eth0
sed -i 's/en[[:alnum:]]*/eth0/g' /etc/network/interfaces;
sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 \1"/g' /etc/default/grub;
update-grub;

# Adding a 2 sec delay to the interface up, to make the dhclient happy
echo "pre-up sleep 2" >> /etc/network/interfaces
