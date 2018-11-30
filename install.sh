#!/bin/bash

set -exo pipefail

start=$(date '+%s%N')

# NTP for time.
timedatectl set-ntp true

# Set up disk partition.
echo "type=83, bootable" | sfdisk --force /dev/sda
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt

read -P "press any key to continue "

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

read -P "press any key to continue "

# Install inside chroot.
curl https://raw.githubusercontent.com/peterstace/archvm/master/chroot.sh > /mnt/chroot.sh
chmod +x /mnt/chroot.sh
arch-chroot /mnt ./chroot.sh

duration=$(echo "($(date '+%s%N') - $start) / 1000000000" | bc)
echo "

Duration: $duration sec

Next steps:

- Shutdown the virtual machine by using `shutdown -h now`.

- Remove the virtual live CD.

- Restart the machine but don't log in.

- SSH into the machine using `ssh -p 2222 petsta@localhost`.

"
