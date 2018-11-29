#!/bin/bash

set -exo pipefail

# Set up SSH keys for Github.
ssh-keygen
set +x
printf "github password > "
read github_password
set -x
payload=$(jq -R "{title: $(hostname | jq -R .), data: .}" ~/.ssh/id_rsa.pub)
curl -u "peterstace:$github_password" --data "$payload"

git clone git@github.com:peterstace/dotfiles.git ~/r/dotfiles
~/r/dotfiles/link.sh
~/r/dotfiles/clone_repos.sh
