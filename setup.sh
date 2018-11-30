#!/bin/bash

set -exo pipefail

systemctl enable dhcpcd.service || false
systemctl enable sshd.socket || false

# Set up SSH keys for Github.
ssh-keygen -N "" -f "$HOME/.ssh/id_rsa"
set +x
printf "github token (must have write:public_key scope) > "
read github_token
set -x
payload=$(jq -R "{title: $(hostname | jq -R .), key: .}" ~/.ssh/id_rsa.pub)
curl -u "peterstace:$github_token" --data "$payload" "https://api.github.com/user/keys"

git clone git@github.com:peterstace/dotfiles.git ~/r/dotfiles
~/r/dotfiles/link.sh
~/r/dotfiles/clone_repos.sh
