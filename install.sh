#!/bin/bash

set -exo pipefail

notice() {
	set +x
	printf '\e[32m'
	echo $@
	printf '\e[0m'
	set -x
}

notice "partitioning disk"
parted /dev/sda mklabel gpt
parted /dev/sda mkpart primary fat32 2048s 1050624s
parted /dev/sda set 1 boot on
parted /dev/sda mkpart primary ext4 1052672s 100%
mkfs -t fat /dev/sda1
mkfs -t ext4 /dev/sda2
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot/

notice "fetching install scripts"
mkdir -p /mnt/archvm
for script in chroot post_install setup; do
	src="https://raw.githubusercontent.com/peterstace/archvm/master/$script.sh"
	dst="/mnt/archvm/$script.sh"
	curl "$src" > "$dst"
	chmod +x "$dst"
done

notice "installing base"
echo '
## Australia
Server = http://ftp.iinet.net.au/pub/archlinux/$repo/os/$arch
Server = http://mirror.internode.on.net/pub/archlinux/$repo/os/$arch
Server = http://ftp.swin.edu.au/archlinux/$repo/os/$arch
Server = http://archlinux.melbourneitmirror.net/$repo/os/$arch
Server = http://archlinux.mirror.digitalpacific.com.au/$repo/os/$arch
' > /etc/pacman.d/mirrorlist
sed -i "$(echo $(sed -n '/\[options\]/=' /etc/pacman.conf) + 1 | bc)iDisableDownloadTimeout" /etc/pacman.conf

pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab
genfstab -U -p /mnt >> /mnt/etc/fstab

notice "entering chroot"
arch-chroot /mnt /archvm/chroot.sh
