#!/bin/bash

set -exo pipefail

dhcpcd
sleep 10 # wait for network to come online

# Install separately due to provider dependencies
pacman --noconfirm --asdeps -S virtualbox-guest-modules-arch
pacman --noconfirm -S virtualbox-guest-utils-nox

# Install remaining packages
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
	fzf \
	genius \
	git \
	gnupg \
	gnuplot \
	go \
	hdparm \
	htop \
	jq \
	ncdu \
	parallel \
	pass \
	postgresql \
	python2 \
	python2-setuptools \
	python3 \
	the_silver_searcher \
	time \
	tmux \
	traceroute \
	unzip \
	vim

systemctl enable dhcpcd.service
systemctl enable sshd.socket
systemctl enable docker.service
systemctl enable vboxservice.service

# Set up user
useradd -m -s /usr/bin/fish petsta
echo "petsta:petsta" | chpasswd
gpasswd -a petsta wheel
gpasswd -a petsta docker
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
