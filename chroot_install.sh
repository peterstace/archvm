#!/bin/bash

set -exo pipefail

ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime
hwclock --systohc
echo "en_AU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo LANG=en_AU.UTF-8 > /etc/locale.conf
echo KEYMAP=dvorak > /etc/vconsole.conf
echo archvm > /etc/hostname
echo "
127.0.0.1   localhost
::1         localhost
127.0.1.1   archvm.localdomain archvm" >> /etc/hosts

pacman -S grub
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

passwd # TODO Can this be automated?

pacman -S sudo
useradd -m -s /bin/bash petsta # TODO Should use fish?
passwd petsta # TODO Can this be automated?
gpasswd -a petsta wheel
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
