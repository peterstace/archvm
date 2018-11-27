#!/bin/bash

set -exo pipefail

# NTP for time.
timedatectl set-ntp true

# Set up disk partition.
echo "type=83, bootable" | sfdisk --force /dev/sda
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt

# Install base
echo '
## Australia
Server = http://ftp.iinet.net.au/pub/archlinux/$repo/os/$arch
Server = http://mirror.internode.on.net/pub/archlinux/$repo/os/$arch
Server = http://ftp.swin.edu.au/archlinux/$repo/os/$arch
Server = http://archlinux.melbourneitmirror.net/$repo/os/$arch
Server = http://archlinux.mirror.digitalpacific.com.au/$repo/os/$arch
' > /etc/pacman.d/mirrorlist
pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab

## Install inside chroot
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime
hwclock --systohc
