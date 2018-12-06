#!/bin/bash

set -exo pipefail

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

git clone git@github.com:peterstace/gpg.git ~/r/gpg
~/r/gpg/setup.sh

dir=$(mktemp -d)
pushd $dir
wget "https://github.com/golang-migrate/migrate/releases/download/v3.5.2/migrate.linux-amd64.tar.gz"
tar -xvzf *.tar.gz
if [ ! -e ~/bin ]; then
    mkdir ~/bin
fi
mv migrate.linux-amd64 ~/bin/migrate
popd

GOPATH="$HOME/go" go get github.com/golang/dep
GOPATH="$HOME/go" go install github.com/golang/dep/...

git clone git@github.com:peterstace/dotfiles.git ~/r/dotfiles
~/r/dotfiles/link.sh
~/r/dotfiles/clone_repos.sh

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
~/.vim/bundle/YouCompleteMe/install.py
vim +GoInstallBinaries +qall

# Create dirs inside PATH (so that fish doesn't complain about having stuff in
# PATH that doesn't exist).
mkdir -p ~/go/bin
