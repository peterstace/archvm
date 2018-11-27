#!/bin/bash

set -exo pipefail

# NTP for time.
timedatectl set-ntp true

# Set up disk partition.
echo "type=83, bootable" | sfdisk /dev/sda
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt
