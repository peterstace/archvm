#!/bin/bash

set -exo pipefail

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

echo "press enter to continue (about to install extra packages) > " && read

pacman --noconfirm -S fish grub openssh sudo wget

echo "press enter to continue (about to install grub) > " && read

grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

echo "press enter to continue (about to set root password) > " && read

echo "root:root" | chpasswd

echo "press enter to continue (about to add user) > " && read

useradd -m -s /usr/bin/fish petsta
echo "petsta:petsta" | chpasswd
gpasswd -a petsta wheel
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
