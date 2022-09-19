#!/usr/bin/bash

set -eux

notice() {
	set +x
	printf '\e[32m%s\n\e[0m' "$@"
	set -x
}

notice "Setting up locale and timezone."
ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime
hwclock --systohc
sed -i '/en_AU.UTF-8/s/#//' /etc/locale.gen
locale-gen
echo LANG=en_AU.UTF-8 > /etc/locale.conf
echo KEYMAP=dvorak > /etc/vconsole.conf

notice "Setting up networking."
echo "archvm$(date +%Y%m%d)" > /etc/hostname
echo "
127.0.0.1   localhost
::1         localhost
127.0.1.1   archvm.localdomain archvm
10.0.2.2    vmhost" > /etc/hosts

notice "Setting up root account."
echo root:root | chpasswd

notice "Disabling DNSSEC."
# Some corporate DNS servers don't play well with DNSSEC.
echo DNSSEC=false >> /etc/systemd/resolved.conf

notice "Setting up DNS for dhcpcd."
echo "static domain_name_servers=8.8.8.8 8.8.4.4" >> /etc/dhcpcd.conf
echo "#static domain_name_servers=10.140.21.86" >> /etc/dhcpcd.conf

notice "Setting shutdown timeout."
echo "DefaultTimeoutStartSec=30s" >> /etc/systemd/system.conf
echo "DefaultTimeoutStopSec=30s" >> /etc/systemd/system.conf

notice "Setting up NTP."
systemctl enable systemd-timesyncd.service

notice "Setting up swap."
# TODO: This isn't idempotent, and fails on second run.
dd if=/dev/zero of=/swapfile bs=1M count=4096 status=progress
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile none swap defaults 0 0" >> /etc/fstab

notice "Installing guest modules."
# Guest modules set up separately from other packages due to provider
# dependencies.
if [ "$(uname -m)" == x86_64 ]; then
	pacman --noconfirm -S virtualbox-guest-utils-nox
fi

notice "Installing extra packages."
# These packages are the minimum needed for rebooting, connecting via SSH, and
# git cloning additional setup scripts as a non-root user.
pacman --noconfirm -S dhcpcd openssh sudo git
systemctl enable dhcpcd.service
systemctl enable sshd.service
echo "
Defaults passwd_timeout=0
%wheel ALL=(ALL) ALL
petsta ALL=(ALL) NOPASSWD: ALL
" >> /etc/sudoers

notice "Creating user."
useradd -m petsta
echo "petsta:petsta" | chpasswd
gpasswd -a petsta wheel

# Set up systemd-boot as the bootloader. A bootloader is used rather than
# directly booting via EFISTUB, since the virtualised UEFI boot menu in
# Parallels and VirtualBox is not easy to use.
notice "Installing bootloader."
bootctl install
[ "$(uname -m)" == "aarch64" ] && vmlinuz="Image"
[ "$(uname -m)" == "x86_64" ] && vmlinuz="vmlinuz-linux"
[ -z "${vmlinuz:-}" ] && echo "unsupported: $(uname -m)" && exit 1
echo "timeout 2" > /boot/loader/loader.conf
echo "
title   Arch Linux
linux   /${vmlinuz}
initrd  /initramfs-linux.img
options root=$part2 rw
" > /boot/loader/entries/arch.conf
bootctl list
