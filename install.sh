#!/bin/bash

set -exo pipefail

notice() {
	printf '\e[32m'
	echo $@
	printf '\e[0m'
}

notice "setting up ntp"
timedatectl set-ntp true

notice "partitioning disk"
echo "type=83, bootable" | sfdisk --force /dev/sda
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt

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
pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab

notice "entering chroot"
arch-chroot /mnt /archvm/chroot.sh
