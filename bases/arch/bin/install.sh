#!/bin/bash

set -euxo pipefail

DISK='/dev/vda'
MOUNT="/mnt"
# BOOT_MOUNT="${MOUNT}/boot"

echo "Creating partitions on ${DISK}"
sgdisk -o -n 1:0:+1M -t 1:EF02 -n 2:0:0 -t 2:8300 "${DISK}"

# echo "Creating boot drive on ${DISK}1"
# mkfs.fat -F32 "${DISK}1"
echo "Creating root filesystem on ${DISK}2"
mkfs.ext4 -L root "${DISK}2"

echo "Mounting ${DISK}2 to ${MOUNT}"
mount -v "${DISK}2" "${MOUNT}"

# echo "Mounting ${DISK}1 to ${BOOT_MOUNT}"
# mkdir -v "${BOOT_MOUNT}"
# mount -v "${DISK}1" "${BOOT_MOUNT}"

echo "Installing base system"
pacman --noconfirm -Sy archlinux-keyring
pacstrap -K "${MOUNT}" base base-devel linux linux-firmware sudo vim wget openssh grub

echo "Generating fstab"
genfstab -U "${MOUNT}" >> "${MOUNT}/etc/fstab"

echo "Generating post installation script"
cat <<'EOF' > "${MOUNT}/post-install.sh"
#!/bin/bash

set -euxo pipefail

# hostname, timezone, locale
echo "LANG=${LOCALE}" > /etc/locale.conf
echo "${HOSTNAME}" > /etc/hostname
ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc
sed -i "s/#${LOCALE}/${LOCALE}/" /etc/locale.gen
locale-gen

# set root password
echo -e '${ROOT_PASSWORD}\n${ROOT_PASSWORD}' | /usr/bin/passwd root

# sshd configuration
SSHD_CONFIG="/etc/ssh/sshd_config"
# ensure that there is a trailing newline before attempting to concatenate
sed -i -e '$a\' "$SSHD_CONFIG"

USEDNS="UseDNS no"
if grep -q -E "^[[:space:]]*UseDNS" "$SSHD_CONFIG"; then
    sed -i "s/^\s*UseDNS.*/${USEDNS}/" "$SSHD_CONFIG"
else
    echo "$USEDNS" >>"$SSHD_CONFIG"
fi
systemctl enable sshd
systemctl start sshd

# network configuration
cat <<EOT > /etc/systemd/network/20-wired.network
[Match]
Name=e*

[Network]
DHCP=yes
EOT
systemctl enable systemd-networkd
systemctl enable systemd-resolved
# use tradtitional interface names
ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules

# create vagrant user
/usr/bin/useradd --comment 'Vagrant User' --create-home --user-group vagrant
echo -e 'vagrant\nvagrant' | /usr/bin/passwd vagrant
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10_vagrant
/usr/bin/chmod 0440 /etc/sudoers.d/10_vagrant

# create vagrant user ssh
HOME_DIR="/home/vagrant"
mkdir -m 0700 -p $HOME_DIR/.ssh

INSECURE_KEY_URL="https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub"
wget --no-check-certificate "$INSECURE_KEY_URL" -O "$HOME_DIR"/.ssh/authorized_keys
chown -R vagrant:vagrant $HOME_DIR/.ssh
chmod 0600 $HOME_DIR/.ssh/authorized_keys
EOF

chmod 0755 "${MOUNT}/post-install.sh"

echo "Chroot-ing into ${MOUNT}"
arch-chroot "${MOUNT}" ./post-install.sh

echo "Installing and configuring grub"
# arch-chroot "${MOUNT}" grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot --removable
arch-chroot "${MOUNT}" grub-install --target=i386-pc "${DISK}"
arch-chroot "${MOUNT}" grub-mkconfig -o /boot/grub/grub.cfg

rm "${MOUNT}/post-install.sh"

echo "Turning down network interfaces and rebooting"
sleep 3
# umount ${BOOT_MOUNT}
umount ${MOUNT}

for i in $(ip -o link show | awk -F': ' '{print $2}');
do
    ip link set "${i}" down;
done
systemctl reboot

echo "Installation complete!"
