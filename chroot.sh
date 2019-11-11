#!/bin/bash

set -exo pipefail

notice() {
	set +x
	printf '\e[32m'
	echo $@
	printf '\e[0m'
	set -x
}

notice "setting up locale"
ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime
hwclock --systohc
echo "en_AU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo LANG=en_AU.UTF-8 > /etc/locale.conf
echo KEYMAP=dvorak > /etc/vconsole.conf
echo "archvm_$(date +%Y%m%d)" > /etc/hostname
echo "
127.0.0.1   localhost
::1         localhost
127.0.1.1   archvm.localdomain archvm" >> /etc/hosts

notice "installing grub"
pacman --noconfirm -S fish grub openssh sudo wget dhcpcd

grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

notice "setting up root password"
echo "root:root" | chpasswd
