#!/bin/bash

set -exo pipefail

dhcpcd
sleep 30 # wait for network to come online

systemctl enable dhcpcd.service
systemctl enable sshd.socket

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
