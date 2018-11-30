#!/bin/bash

set -exo pipefail

ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime
hwclock --systohc
echo "en_AU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo LANG=en_AU.UTF-8 > /etc/locale.conf
echo KEYMAP=dvorak > /etc/vconsole.conf
echo "archvm_$(date +%Y%m%d)" > /etc/hostname
echo "
127.0.0.1   localhost
::1         localhost
127.0.1.1   archvm.localdomain archvm" >> /etc/hosts

pacman --noconfirm -S \
	aws-cli \
	base-devel \
	clang \
	cmake \
	diff-so-fancy \
	docker \
	docker-compose \
	dos2unix \
	exa \
	expect \
	fish \
	fzf \
	genius \
	git \
	gnupg \
	gnuplot \
	go \
	grub \
	hdparm \
	htop \
	jq \
	ncdu \
	openssh \
	parallel \
	pass \
	postgresql \
	python2 \
	python2-setuptools \
	python3 \
	sudo \
	the_silver_searcher \
	time \
	tmux \
	traceroute \
	unzip \
	vim \
	wget \
	zsh

grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

echo "root:root" | chpasswd

useradd -m -s /usr/bin/fish petsta
echo "petsta:petsta" | chpasswd
gpasswd -a petsta wheel
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
