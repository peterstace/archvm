#!/usr/bin/bash

set -eux

notice() {
	set +x
	printf '\e[32m%s\n\e[0m' "$@"
	set -x
}

notice "Checking UEFI boot mode."
test -d /sys/firmware/efi/efivars

notice "Updating system clock."
timedatectl set-ntp true

notice "Preparing disk."
for dev in /dev/sda1 /dev/sda2; do
	if grep $dev /etc/mtab -q; then
		umount $dev
	fi
done
parted -s /dev/sda mklabel gpt
parted -s /dev/sda mkpart primary fat32 0% 512MiB
parted -s /dev/sda mkpart primary ext4 512MiB 100%
parted -s /dev/sda set 1 esp on
parted -s /dev/sda set 1 boot on
mkfs.fat -F 32 /dev/sda1
mkfs.ext4 -F /dev/sda2
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

notice "Fetching chroot script."
# Done as early as possible (after preparing the location to save it to) in
# case internet connectivity is not working.
mkdir -p /mnt/archvm
src="https://raw.githubusercontent.com/peterstace/archvm/master/chroot.sh"
dst="/mnt/archvm/chroot.sh"
curl "$src" > "$dst"
chmod +x "$dst"

notice "Selecting mirrors."
# Only needed for x86_64, because aarch64 mirrors do GeoIP based balancing. The
# reflector package doesn't exist for aarch64.
if [ "$(uname -m)" == x86_64 ]; then
	# TODO: disable the reflector daemon so that it doesn't try to overwrite
	# the mirror list.
	reflector --country Australia --sort rate > /etc/pacman.d/mirrorlist
fi

notice "Installing base."
exec bash
pacstrap /mnt base linux linux-firmware

notice "Generating fstab."
genfstab -U /mnt >> /mnt/etc/fstab

notice "Run chroot script."
arch-chroot /mnt /archvm/chroot.sh

notice "Shutdown notice."
echo "Installation complete. You can now:"
echo "  - Shutdown the VM using \`shutdown -h now\`"
echo "  - Remove the installation media"
echo "  - restart the VM"
