#!/bin/bash

set -exo pipefail

# NTP for time.
timedatectl set-ntp true

# Set up disk partition.
echo "type=83, bootable" | sfdisk --force /dev/sda
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt

# Obtain all install scripts
mkdir -p /mnt/archvm
for script in chroot post_install setup; do
	src="https://raw.githubusercontent.com/peterstace/archvm/master/$script.sh"
	dst="/mnt/archvm/$script.sh"
	curl "$src" > "$dst"
	chmod +x "$dst"
done

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

# Install inside chroot.
arch-chroot /mnt /archvm/chroot.sh
