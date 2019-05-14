#!/bin/bash

set -exo pipefail

notice() {
    set +x
    printf '\e[32m'
    echo $@
    printf '\e[0m'
    set -x
}

#
# Requires interaction:
#

notice "setting up github keys"
ssh-keygen -N "" -f "$HOME/.ssh/id_rsa"
set +x
printf "github token (must have write:public_key scope) > "
read github_token
set -x
payload=$(jq -R "{title: $(hostname | jq -R .), key: .}" ~/.ssh/id_rsa.pub)
curl \
    -u "peterstace:$github_token" \
    --data "$payload" \
    "https://api.github.com/user/keys"

notice "installing GPG keys"
git clone git@github.com:peterstace/gpg.git ~/r/gpg
~/r/gpg/setup.sh

#
# Doesn't require interaction.
#

notice "setting up dotfiles"
git clone git@github.com:peterstace/dotfiles.git ~/r/dotfiles
~/r/dotfiles/link.sh

notice "cloning repos"
~/r/dotfiles/clone_repos.sh

notice "installing vim plugins"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall

notice "installing dep"
GOPATH="$HOME/go" go get github.com/golang/dep/...

notice "installing personal Go binaries (already cloned)"
GOPATH="$HOME/go" go install github.com/peterstace/dauntless/...
GOPATH="$HOME/go" go install github.com/peterstace/task/...
GOPATH="$HOME/go" go install github.com/peterstace/cliscreensaver/...
GOPATH="$HOME/go" go install github.com/peterstace/abacus/...
GOPATH="$HOME/go" go install github.com/peterstace/csvfmt/...
GOPATH="$HOME/go" go install github.com/peterstace/tmuxssel/...
GOPATH="$HOME/go" go install github.com/peterstace/vmbridge/...

notice "installing public Go binaries"
GOPATH="$HOME/go" go get github.com/kardianos/govendor/...
