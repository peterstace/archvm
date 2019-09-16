#!/bin/bash

set -exo pipefail

notice() {
	set +x
	printf '\e[32m'
	echo $@
	printf '\e[0m'
	set -x
}

notice "setting up initial network connectivity"
dhcpcd
sleep 10 # wait for network to come online

notice "setting shutdown timeout"
echo "DefaultTimeoutStartSec=30s" >> /etc/systemd/system.conf
echo "DefaultTimeoutStopSec=30s" >> /etc/systemd/system.conf

# Install separately due to provider dependencies
notice "installing guest modules"
pacman --noconfirm --asdeps -S virtualbox-guest-modules-arch
pacman --noconfirm -S virtualbox-guest-utils-nox

# Install remaining packages
notice "installing packages"
pacman --noconfirm -S \
	aws-cli \
	base-devel \
	bat \
	bc \
	clang \
	cmake \
	diff-so-fancy \
	docker \
	docker-compose \
	dos2unix \
	exa \
	expect \
	fzf \
	genius \
	git \
	gnupg \
	gnuplot \
	go \
	hdparm \
	htop \
	hub \
	jq \
	lapacke \
	ncdu \
	octave \
	parallel \
	pass \
	postgresql \
	python-pip \
	python2 \
	python2-pip \
	python2-setuptools \
	python3 \
	rust \
	the_silver_searcher \
	time \
	tmux \
	traceroute \
	unzip \
	vim \
	yq \
	zip

notice "setting up DNS"
echo "static domain_name_servers=8.8.8.8 8.8.4.4" >> /etc/dhcpcd.conf

notice "enabling services"
systemctl enable dhcpcd.service
systemctl enable sshd.socket
systemctl enable docker.service
systemctl enable vboxservice.service

notice "enabling swap"
fallocate -l 16G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile none swap defaults 0 0" >> /etc/fstab

notice "setting up user"
useradd -m -s /usr/bin/fish petsta
echo "petsta:petsta" | chpasswd
gpasswd -a petsta wheel
gpasswd -a petsta docker
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo "Defaults passwd_timeout=0" >> /etc/sudoers
