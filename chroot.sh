#!/usr/bin/bash

set -eux

# Set up locale and TZ.
ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime
hwclock --systohc
sed -i '/en_AU.UTF-8/s/#//' /etc/locale.gen
locale-gen
echo LANG=en_AU.UTF-8 > /etc/locale.conf
echo KEYMAP=dvorak > /etc/vconsole.conf

# Set up networking.
echo "archvm$(date +%Y%m%d)" > /etc/hostname
echo "
127.0.0.1   localhost
::1         localhost
127.0.1.1   archvm.localdomain archvm
10.0.2.2    vmhost" > /etc/hosts

# Set up root account.
echo root:root | chpasswd

# Disable DNSSEC. Some corporate DNS servers don't play well with DNSSEC.
echo DNSSEC=false >> /etc/systemd/resolved.conf

# Setting up DNS for dhcpcd.
echo "static domain_name_servers=8.8.8.8 8.8.4.4" >> /etc/dhcpcd.conf

# Setting shutdown timeout
echo "DefaultTimeoutStartSec=30s" >> /etc/systemd/system.conf
echo "DefaultTimeoutStopSec=30s" >> /etc/systemd/system.conf

# Set up NTP.
timedatectl set-ntp 1

# Enable swap.
# TODO: This isn't idempotent, and fails on second run.
dd if=/dev/zero of=/swapfile bs=1M count=512 status=progress
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile none swap defaults 0 0" >> /etc/fstab

# Install guest modules (separately due to provider dependencies). Only
# available on x86_64.
if [ "$(uname -m)" == x86_64 ]; then
	pacman --noconfirm -S virtualbox-guest-utils-nox
fi

# Install minimum set of packages needed for rebooting, connecting via SSH, and
# git cloning additional setup scripts as a non-root user.
pacman --noconfirm -S dhcpcd openssh sudo git
systemctl enable dhcpcd.service
systemctl enable sshd.service
echo "Defaults passwd_timeout=0" >> /etc/sudoers
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Create user.
useradd -m petsta
echo "petsta:petsta" | chpasswd
gpasswd -a petsta wheel

# Set up systemd-boot as the bootloader. A bootloader is used rather than
# directly booting via EFISTUB, since the virtualised UEFI boot menu in
# Parallels and VirtualBox is not easy to use.
bootctl install
[ "$(uname -m)" == "aarch64" ] && vmlinuz="Image"
[ "$(uname -m)" == "x84_64" ] && vmlinuz="vmlinuz-linux"
[ -z "${vmlinuz:-}" ] && echo "unsupported: $(uname -m)" && exit 1
echo "timeout 2" > /boot/loader/loader.conf
echo "
title   Arch Linux
linux   /${vmlinuz}
initrd  /initramfs-linux.img
options root=/dev/sda2 rw
" > /boot/loader/entries/arch.conf
bootctl list
