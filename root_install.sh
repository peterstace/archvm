#!/bin/bash

set -exo pipefail

# NTP for time.
timedatectl set-ntp true

# Set up disk partition.
printf "n\n\n\n\na\nw\n" | fdisk /dev/sda
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt
