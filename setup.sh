#!/bin/bash

set -exo pipefail

notice() {
	set +x
	printf '\e[32m'
	echo $@
	printf '\e[0m'
	set -x
}

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

notice "installing migrate"
dir=$(mktemp -d)
pushd $dir
wget "https://github.com/golang-migrate/migrate/releases/download/v3.5.2/migrate.linux-amd64.tar.gz"
tar -xvzf *.tar.gz
if [ ! -e ~/bin ]; then
    mkdir ~/bin
fi
mv migrate.linux-amd64 ~/bin/migrate
popd

notice "installing dep"
GOPATH="$HOME/go" go get github.com/golang/dep
GOPATH="$HOME/go" go install github.com/golang/dep/...

notice "setting up dotfiles"
git clone git@github.com:peterstace/dotfiles.git ~/r/dotfiles
~/r/dotfiles/link.sh

notice "cloning repos"
~/r/dotfiles/clone_repos.sh

notice "installing personal Go binaries"
GOPATH="$HOME/go" go install github.com/peterstace/dauntless/...
GOPATH="$HOME/go" go install github.com/peterstace/task/...

notice "installing vim plugins"
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
~/.vim/bundle/YouCompleteMe/install.py
vim +GoInstallBinaries +qall
