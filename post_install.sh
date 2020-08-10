#!/bin/bash

set -exo pipefail

notice() {
	set +x
	printf '\e[32m'
	echo $@
	printf '\e[0m'
	set -x
}

notice "setting up DNS"
echo DNSSEC=false >> /etc/systemd/resolved.conf
systemctl restart systemd-resolved.service
sleep 10 # wait for restart

notice "setting up initial network connectivity"
dhcpcd
sleep 10 # wait for network to come online

notice "setting shutdown timeout"
echo "DefaultTimeoutStartSec=30s" >> /etc/systemd/system.conf
echo "DefaultTimeoutStopSec=30s" >> /etc/systemd/system.conf

# Install separately due to provider dependencies
notice "installing guest modules"
pacman --noconfirm -S virtualbox-guest-utils-nox

# Install remaining packages
notice "installing packages"
pacman --noconfirm -S \
	aws-cli \
	base-devel \
	bash-completion \
	bat \
	bc \
	bind-tools \
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
	graphviz \
	hdparm \
	htop \
	hub \
	inetutils \
	jq \
	kustomize \
	lapacke \
	man \
	man-pages \
	ncdu \
	octave \
	parallel \
	pass \
	postgresql \
	proj \
	python-pip \
	python2 \
	python2-pip \
	python2-setuptools \
	python3 \
	ripgrep \
	rust \
	the_silver_searcher \
	time \
	tmux \
	traceroute \
	unzip \
	vim \
	yq \
	zip \
	zsh \
	zsh-completions

notice "setting up DNS"
echo "static domain_name_servers=8.8.8.8 8.8.4.4" >> /etc/dhcpcd.conf

notice "enabling services"
systemctl enable dhcpcd.service
systemctl enable sshd.service
systemctl enable docker.service
systemctl enable vboxservice.service

notice "setting up NTP"
timedatectl set-ntp 1

notice "enabling swap"
dd if=/dev/zero of=/swapfile bs=1M count=16384 status=progress
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
