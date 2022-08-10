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

if [ -e /dev/sda ]; then
	device=/dev/sda
	part1=${device}1
	part2=${device}2
elif [ -e /dev/nvme0n1 ]; then
	device=/dev/nvme0n1
	part1=${device}p1
	part2=${device}p2
else
	echo "can't determine disk"
	exit 1
fi
export part2 # needed inside chroot

notice "Preparing disk."
for part in $part1 $part2; do
	if grep $part /etc/mtab -q; then
		umount $part
	fi
done
parted -s $device mklabel gpt
parted -s $device mkpart primary fat32 0% 512MiB
parted -s $device mkpart primary ext4 512MiB 100%
parted -s $device set 1 esp on
parted -s $device set 1 boot on
mkfs.fat -F 32 $part1
mkfs.ext4 -F $part2
mount $part2 /mnt
mkdir /mnt/boot
mount $part1 /mnt/boot

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

###  TODO: put this behind a hack toggle
###
###  notice "Updating keyring."
###  # The master key may have been created when the wrong local time was set. In
###  # order to fix that, remove the keys completely before setting up new keys. See
###  # https://bbs.archlinux.org/viewtopic.php?id=201776 for details.
###  rm -rf /etc/pacman.d/gnupg
###  pacman-key --init
###  # For aarch64, see https://archlinuxarm.org/about/package-signing for details.
###  pacman-key --populate "archlinux$(uname -m | sed -e 's!aarch64!arm!' -e 's!x86_64!!')"
###  pacman --noconfirm -Sy archlinux-keyring

notice "Installing base."
pacstrap /mnt base linux linux-firmware

notice "Generating fstab."
genfstab -U /mnt >> /mnt/etc/fstab

notice "Run chroot script."
###  TODO: put this behind a hack toggle
###
###  if grep /mnt/dev /etc/mtab -q; then
###  	# This is to work around a bug in arch-chroot, see
###  	# https://bbs.archlinux.org/viewtopic.php?id=278432
###  	umount /mnt/dev
###  fi
arch-chroot /mnt /archvm/chroot.sh

notice "Shutdown notice."
echo "Installation complete. You can now:"
echo "  - Shutdown the VM using \`shutdown -h now\`"
echo "  - Remove the installation media"
echo "  - restart the VM"
